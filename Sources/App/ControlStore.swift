import AppKit
import SwiftUI
import UniformTypeIdentifiers

/// Owns the visible snapshot and explicitly user-authorized local mutations.
@MainActor
internal final class ControlStore: ObservableObject {
    @Published internal private(set) var snapshot: RepositorySnapshot?
    @Published internal private(set) var state = WorkspaceState()
    @Published internal private(set) var storageReady = true
    @Published internal private(set) var loading = false
    @Published internal var selection: String?
    @Published internal var error: String?
    @Published internal private(set) var syncFailure: String?
    private var fingerprint: [String] = []
    private var pendingRoot: URL?
    private let storage: WorkspaceStorage
    private let preferences: UserDefaults
    private let fingerprintRepository: @Sendable (RepositorySnapshot) -> [String]
    private let readRepository: @Sendable (URL) throws -> RepositorySnapshot

    /// Loads the independent local workspace without modifying the repository.
    /// - Parameters:
    ///   - storage: Optional isolated storage.
    ///   - preferences: Repository preferences.
    ///   - fingerprintRepository: Background content checker.
    ///   - readRepository: Background snapshot reader.
    /// - Returns: A store with either restored data or a visible read-only failure.
    internal init(storage: WorkspaceStorage? = nil, preferences: UserDefaults = .standard,
                  fingerprintRepository: @escaping @Sendable (RepositorySnapshot) -> [String] = { RepositoryReader.fingerprint($0) },
                  readRepository: @escaping @Sendable (URL) throws -> RepositorySnapshot = { try RepositoryReader.load($0) }) {
        if let storage { self.storage = storage }
        else {
            let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            self.storage = WorkspaceStorage(file: support.appendingPathComponent(ControlConstants.appName)
                .appendingPathComponent(ControlConstants.stateFile))
        }
        self.preferences = preferences
        self.fingerprintRepository = fingerprintRepository
        self.readRepository = readRepository
        do { state = try self.storage.load() }
        catch { storageReady = false; self.error = ControlConstants.stateFailure }
    }

    internal var selectedProject: ProjectRecord? {
        snapshot?.projects.first { $0.id == selection }
    }

    /// Restores the chosen repository and observes changes only while the view is alive.
    /// - Returns: Nothing; cancellation ends the polling lifecycle.
    internal func observe() async {
        if snapshot == nil, let path = preferences.string(forKey: ControlConstants.folderPreference) {
            await reload(URL(fileURLWithPath: path))
        }
        while !Task.isCancelled {
            do { try await Task.sleep(for: .seconds(ControlConstants.refreshSeconds)) }
            catch { return }
            guard !loading else { continue }
            if let snapshot {
                let current = await Task.detached(priority: .utility) { [fingerprintRepository] in fingerprintRepository(snapshot) }.value
                guard !Task.isCancelled else { return }
                guard !loading else { continue }
                if self.snapshot?.root == snapshot.root && (current != fingerprint || syncFailure != nil) {
                    await reload(snapshot.root)
                }
            } else if let path = preferences.string(forKey: ControlConstants.folderPreference) {
                await reload(URL(fileURLWithPath: path))
            }
        }
    }

    /// Offers a native folder picker; cancellation leaves the current repository unchanged.
    /// - Returns: Nothing; a valid selection refreshes asynchronously.
    internal func chooseRepository() {
        let panel = NSOpenPanel()
        panel.title = ControlConstants.chooseRepository
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        guard panel.runModal() == .OK, let url = panel.url else { return }
        Task { await reload(url) }
    }

    /// Parses a complete snapshot off the UI thread before replacing the current view.
    /// - Parameter root: User-selected repository directory.
    /// - Returns: Nothing; retains the last snapshot on failure and services the latest queued selection.
    internal func reload(_ root: URL) async {
        guard !loading else { pendingRoot = root; return }
        loading = true
        defer { loading = false; pendingRoot = nil }
        var nextRoot: URL? = root
        while let target = nextRoot {
            pendingRoot = nil
            do {
                let result = try await Task.detached(priority: .userInitiated) { [readRepository] in
                    try readRepository(target)
                }.value
                guard !Task.isCancelled else { return }
                let previous = snapshot?.root == result.root ? snapshot?.projects ?? [] : []
                let projects = result.projects.map { current -> ProjectRecord in
                    guard let warning = current.sourceWarning,
                          var retained = previous.first(where: { $0.id == current.id && ($0.sourceWarning == nil || $0.isStale) }) else { return current }
                    retained.name = current.name
                    retained.classification = current.classification
                    retained.folderAvailable = current.folderAvailable
                    retained.readmeAvailable = current.readmeAvailable
                    retained.applications = current.applications
                    retained.sourceWarning = warning
                    retained.isStale = true
                    return retained
                }
                snapshot = RepositorySnapshot(root: result.root, projects: projects, history: result.history,
                    readAt: result.readAt, fingerprint: result.fingerprint, overview: result.overview,
                    commitActivity: result.commitActivity)
                syncFailure = nil
                fingerprint = result.fingerprint
                if selection != result.root.path && !result.projects.contains(where: { $0.id == selection }) {
                    selection = result.root.path
                }
                preferences.set(result.root.path, forKey: ControlConstants.folderPreference)
                error = storageReady ? nil : ControlConstants.stateFailure
            } catch {
                let failure = (error as? ControlFailure)?.message ?? ControlConstants.readFailure
                if snapshot == nil || snapshot?.root == target.resolvingSymlinksInPath().standardizedFileURL {
                    syncFailure = failure
                }
                self.error = failure
            }
            nextRoot = pendingRoot
        }
    }

    /// Returns the project's local notes without creating state merely by reading it.
    /// - Parameter project: Canonical project identifier.
    /// - Returns: Saved notes, or an empty list on first use.
    internal func notes(for project: String) -> [WorkNote] { state.notes[project] ?? [] }

    /// Saves an inserted or edited work note before presenting it as committed.
    /// - Parameters:
    ///   - note: Proposed note.
    ///   - project: Canonical project identifier.
    /// - Returns: Whether the local atomic save succeeded.
    internal func save(_ note: WorkNote, for project: String) -> Bool {
        guard note.isValid else { error = ControlConstants.noteLimit; return false }
        var next = state
        var notes = notes(for: project)
        if let index = notes.firstIndex(where: { $0.id == note.id }) { notes[index] = note }
        else { notes.append(note) }
        next.notes[project] = notes
        return persist(next)
    }

    /// Removes a user-confirmed note without changing the project or README.
    /// - Parameters:
    ///   - note: Confirmed target.
    ///   - project: Owning project identifier.
    /// - Returns: Nothing; failures leave the original note intact.
    internal func delete(_ note: WorkNote, for project: String) {
        var next = state
        next.notes[project] = notes(for: project).filter { $0.id != note.id }
        _ = persist(next)
    }

    /// Persists a candidate state before publishing it to the UI.
    /// - Parameter next: Candidate notes and launch preferences.
    /// - Returns: True only after a successful atomic write.
    private func persist(_ next: WorkspaceState) -> Bool {
        guard storageReady else { error = ControlConstants.stateFailure; return false }
        do { try storage.save(next); state = next; return true }
        catch { self.error = ControlConstants.saveFailure; return false }
    }

    /// Opens an explicitly requested folder or README, rechecking the repository boundary.
    /// - Parameter url: Project folder or README URL from the current snapshot.
    /// - Returns: Nothing; failed open actions display a recoverable message.
    internal func open(_ url: URL) {
        guard let snapshot, RepositoryReader.contains(url, in: snapshot.root) else {
            error = ControlConstants.openFailure
            return
        }
        if !NSWorkspace.shared.open(url) { error = ControlConstants.openFailure }
    }

    /// Locates and opens an app only after an explicit Open App action.
    /// - Parameter project: Project whose missing launch target the user is locating.
    /// - Returns: Nothing; cancellation leaves the existing target intact and launches nothing.
    internal func chooseApplication(for project: ProjectRecord) {
        let panel = NSOpenPanel()
        panel.title = ControlConstants.chooseApp
        panel.message = ControlConstants.launchExplanation
        panel.prompt = ControlConstants.launch
        panel.directoryURL = project.folder
        panel.allowedContentTypes = [.applicationBundle]
        panel.allowsMultipleSelection = false
        guard panel.runModal() == .OK, let url = panel.url else { return }
        launch(project, selectedApp: url)
    }

    /// Removes a configured launch choice without touching the application itself.
    /// - Parameter project: Owning project identifier.
    /// - Returns: Nothing; a failure leaves the preference unchanged.
    internal func clearApplication(for project: String) {
        var next = state
        next.applications.removeValue(forKey: project)
        _ = persist(next)
    }

    /// Resolves an automatic target before a valid remembered manual choice.
    /// - Parameters:
    ///   - project: Owning project.
    ///   - candidates: Optional fresh discovery results for click-time validation.
    /// - Returns: An unambiguous application, or nil when selection or manual location is needed.
    internal func application(for project: ProjectRecord, candidates: [URL]? = nil) -> URL? {
        let available = (candidates ?? project.applications).filter { ApplicationLocator.isCurrentCandidate($0, for: project) }
        if let automatic = ApplicationLocator.preferred(available, project: project.name, folder: project.folder) { return automatic }
        if let path = state.applications[project.id] {
            let saved = URL(fileURLWithPath: path)
            if ApplicationLocator.isApplication(saved) { return saved }
        }
        return nil
    }

    /// Rechecks discovery on click and opens only an automatic or explicitly chosen application.
    /// - Parameters:
    ///   - project: Owning project.
    ///   - selectedApp: Explicit choice from detected candidates or a native picker.
    /// - Returns: Nothing; missing apps offer location, and launch/save errors remain visible.
    internal func launch(_ project: ProjectRecord, selectedApp: URL? = nil) {
        guard let root = snapshot?.root,
              project.folder.resolvingSymlinksInPath().standardizedFileURL.path == project.id,
              RepositoryReader.contains(project.folder, in: root) else {
            error = ControlConstants.unsafeProject; return
        }
        let candidates = ApplicationLocator.candidates(in: project.folder, within: root).filter(ApplicationLocator.isApplication)
        guard let url = selectedApp ?? application(for: project, candidates: candidates) else {
            chooseApplication(for: project)
            return
        }
        guard ApplicationLocator.isApplication(url) else {
            error = ControlConstants.invalidApplication; return
        }
        if selectedApp != nil && storageReady {
            var next = state
            next.applications[project.id] = url.path
            _ = persist(next)
        }
        NSWorkspace.shared.openApplication(at: url, configuration: NSWorkspace.OpenConfiguration()) { [weak self] _, failure in
            guard failure != nil else { return }
            Task { @MainActor in self?.error = ControlConstants.openFailure }
        }
    }
}
