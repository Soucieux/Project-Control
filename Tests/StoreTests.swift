import Foundation

/// Isolated state-transition checks; never loads the user's workspace or launches applications.
@main
@MainActor
internal enum StoreTests {
    private static var count = 0

    /// Exercises queued reloads and atomic note mutations with disposable local state.
    /// - Returns: Nothing; exits unsuccessfully on a failed check or fixture error.
    internal static func main() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(TestConstants.rootName + UUID().uuidString)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }
        // A suite named by a path keeps its plist inside the disposable root; a plain name would leave an
        // empty file in ~/Library/Preferences after every run, even once the domain is removed.
        let suite = root.appendingPathComponent(TestConstants.preferencesSuite).path
        guard let preferences = UserDefaults(suiteName: suite) else { fatalError(TestConstants.failed) }
        defer { preferences.removePersistentDomain(forName: suite) }
        let firstRoot = root.appendingPathComponent(TestConstants.project)
        let secondRoot = root.appendingPathComponent(TestConstants.secondRepository)
        for folder in [firstRoot, secondRoot] {
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            try TestConstants.rootReadme.write(to: folder.appendingPathComponent(ControlConstants.readme), atomically: true, encoding: .utf8)
        }
        let storage = WorkspaceStorage(file: root.appendingPathComponent(ControlConstants.stateFile))
        if CommandLine.arguments.contains(TestConstants.activityOnly) {
            await activityPublishingCheck(secondRoot, storage: storage, preferences: preferences)
            print(TestConstants.storePassed + String(count))
            return
        }
        if CommandLine.arguments.contains(TestConstants.classificationOnly) {
            try await classificationRecoveryCheck(secondRoot, storage: storage, preferences: preferences)
            print(TestConstants.storePassed + String(count))
            return
        }
        let started = DispatchSemaphore(value: 0)
        let release = DispatchSemaphore(value: 0)
        let store = ControlStore(storage: storage, preferences: preferences, readRepository: { url in
            if url == firstRoot {
                started.signal()
                guard release.wait(timeout: .now() + 5) == .success else {
                    throw ControlFailure(message: TestConstants.checkReaderStarted)
                }
            }
            return try RepositoryReader.load(url)
        })
        let first = Task { await store.reload(firstRoot) }
        let didStart = await withCheckedContinuation { continuation in
            DispatchQueue.global().async {
                continuation.resume(returning: started.wait(timeout: .now() + 5) == .success)
            }
        }
        check(didStart, TestConstants.checkReaderStarted)
        await store.reload(secondRoot)
        release.signal()
        await first.value
        check(store.snapshot?.root == secondRoot.resolvingSymlinksInPath(), TestConstants.checkStoreQueue)
        check(!store.loading && store.error == nil, TestConstants.checkStoreLoading)
        check(preferences.string(forKey: ControlConstants.folderPreference) == secondRoot.resolvingSymlinksInPath().path, TestConstants.checkStorePreference)
        try await refreshCheck(secondRoot, storage: storage, preferences: preferences)
        await navigationChecks(secondRoot, storage: storage, preferences: preferences)
        await activityPublishingCheck(secondRoot, storage: storage, preferences: preferences)
        try await sourceRecoveryChecks(secondRoot, storage: storage, preferences: preferences)
        try await classificationRecoveryCheck(secondRoot, storage: storage, preferences: preferences)
        try await initialRecoveryCheck(root, storage: storage, preferences: preferences)
        try await pollingRaceCheck(root, storage: storage, preferences: preferences)
        try applicationChecks(secondRoot, storage: storage, preferences: preferences)
        let note = WorkNote(text: TestConstants.title + ControlConstants.newline + TestConstants.detail)
        check(try store.save(note, for: TestConstants.project) && storage.load().notes[TestConstants.project] == [note], TestConstants.checkStoreSave)
        var edited = note
        edited.text = TestConstants.detail
        check(store.save(edited, for: TestConstants.project) && store.notes(for: TestConstants.project) == [edited], TestConstants.checkStoreEdit)
        store.delete(edited, for: TestConstants.project)
        check(try storage.load().notes[TestConstants.project] == [], TestConstants.checkStoreDelete)
        try TestConstants.corrupt.write(to: storage.file, atomically: true, encoding: .utf8)
        let locked = ControlStore(storage: storage, preferences: preferences)
        check(try !locked.storageReady && !locked.save(note, for: TestConstants.project)
            && String(contentsOf: storage.file, encoding: .utf8) == TestConstants.corrupt, TestConstants.checkStoreCorrupt)
        let blocked = root.appendingPathComponent(TestConstants.blockedFile)
        try TestConstants.corrupt.write(to: blocked, atomically: true, encoding: .utf8)
        let failing = ControlStore(storage: WorkspaceStorage(file: blocked.appendingPathComponent(ControlConstants.stateFile)), preferences: preferences)
        check(!failing.save(note, for: TestConstants.project) && failing.notes(for: TestConstants.project).isEmpty, TestConstants.checkStoreFailedSave)
        print(TestConstants.storePassed + String(count))
    }

    /// Confirms that store publication preserves the complete activity supplied by the repository reader.
    /// - Parameters:
    ///   - root: Disposable selected repository.
    ///   - storage: Isolated local state.
    ///   - preferences: Isolated repository preference.
    /// - Returns: Nothing; terminates if activity is discarded or recalculated.
    private static func activityPublishingCheck(_ root: URL, storage: WorkspaceStorage, preferences: UserDefaults) async {
        let expected = CommitActivity(years: [CommitActivityYear(year: 2026,
            months: Array(repeating: 1, count: ControlConstants.monthCount))], totalCount: 12, available: true)
        let result = RepositorySnapshot(root: root.resolvingSymlinksInPath().standardizedFileURL,
            projects: [], history: [], readAt: Date(), fingerprint: [], commitActivity: expected)
        let store = ControlStore(storage: storage, preferences: preferences, readRepository: { _ in result })
        await store.reload(root)
        check(store.snapshot?.commitActivity == expected, TestConstants.checkActivityStore)
    }

    /// Preserves project identity and notes while root-owned classification changes over stale content.
    /// - Parameters:
    ///   - root: Disposable repository.
    ///   - storage: Isolated note storage.
    ///   - preferences: Isolated repository preferences.
    /// - Returns: Nothing; fails if project-content recovery masks authoritative root metadata.
    private static func classificationRecoveryCheck(_ root: URL, storage: WorkspaceStorage, preferences: UserDefaults) async throws {
        let readme = root.appendingPathComponent(ControlConstants.readme)
        let projectReadme = root.appendingPathComponent(TestConstants.project).appendingPathComponent(ControlConstants.readme)
        try FileManager.default.createDirectory(at: projectReadme.deletingLastPathComponent(), withIntermediateDirectories: true)
        try TestConstants.classifiedRoot.write(to: readme, atomically: true, encoding: .utf8)
        try TestConstants.mappedReadme.write(to: projectReadme, atomically: true, encoding: .utf8)
        let store = ControlStore(storage: storage, preferences: preferences)
        await store.reload(root)
        guard let project = store.snapshot?.projects.first else { fatalError(TestConstants.checkClassification) }
        store.selection = project.id
        let existingNotes = store.notes(for: project.id)
        let note = WorkNote(text: TestConstants.title + ControlConstants.newline + TestConstants.detail)
        check(store.save(note, for: project.id), TestConstants.checkSyncNotes)
        try TestConstants.invalidMappings[0].write(to: projectReadme, atomically: true, encoding: .utf8)
        try TestConstants.classifiedRoot.replacingOccurrences(of: TestConstants.managementCategory, with: TestConstants.renamedCategory)
            .replacingOccurrences(of: TestConstants.readmeDriven, with: TestConstants.hostedAI)
            .write(to: readme, atomically: true, encoding: .utf8)
        await store.reload(root)
        check(store.selectedProject?.isStale == true && store.selectedProject?.architecture.isEmpty == false
            && store.selectedProject?.classification.category == TestConstants.renamedCategory
            && store.selectedProject?.classification.technologies == [TestConstants.swiftUI, TestConstants.hostedAI], TestConstants.checkClassificationStale)
        check(store.selection == project.id && store.notes(for: project.id) == existingNotes + [note], TestConstants.checkSyncNotes)
        try TestConstants.mappedRoot.write(to: readme, atomically: true, encoding: .utf8)
        await store.reload(root)
        check(store.selectedProject?.isStale == true && store.selectedProject?.classification == ProjectClassification(),
            TestConstants.checkClassificationStale)
        check(store.selection == project.id && store.notes(for: project.id) == existingNotes + [note], TestConstants.checkSyncNotes)
    }

    /// Keeps failures isolated while applying valid edits, removals, and source recovery.
    /// - Parameters:
    ///   - root: Disposable repository.
    ///   - storage: Isolated local notes.
    ///   - preferences: Isolated preferences.
    /// - Returns: Nothing; fails if stale state or local data is mishandled.
    private static func sourceRecoveryChecks(_ root: URL, storage: WorkspaceStorage, preferences: UserDefaults) async throws {
        let readme = root.appendingPathComponent(ControlConstants.readme)
        let projectReadme = root.appendingPathComponent(TestConstants.project).appendingPathComponent(ControlConstants.readme)
        try TestConstants.mappedRoot.write(to: readme, atomically: true, encoding: .utf8)
        try TestConstants.mappedReadme.write(to: projectReadme, atomically: true, encoding: .utf8)
        let store = ControlStore(storage: storage, preferences: preferences)
        await store.reload(root)
        guard let project = store.snapshot?.projects.first else { fatalError(TestConstants.checkMappedRoot) }
        store.selection = project.id
        let note = WorkNote(text: TestConstants.title + ControlConstants.newline + TestConstants.detail)
        check(store.save(note, for: project.id), TestConstants.checkSyncNotes)
        try TestConstants.invalidMappings[0].write(to: projectReadme, atomically: true, encoding: .utf8)
        try TestConstants.mappedRoot.replacingOccurrences(of: TestConstants.repositoryOverview, with: TestConstants.updatedRepositoryOverview)
            .write(to: readme, atomically: true, encoding: .utf8)
        await store.reload(root)
        check(store.selectedProject?.isStale == true && store.selectedProject?.sourceWarning == ControlConstants.mappingFailure
            && store.selectedProject?.architecture.isEmpty == false, TestConstants.checkStaleProject)
        check(store.snapshot?.overview.first?.text == TestConstants.updatedRepositoryOverview, TestConstants.checkIndependentSync)
        check(store.selection == project.id && store.notes(for: project.id) == [note], TestConstants.checkSyncNotes)
        try FileManager.default.removeItem(at: projectReadme)
        await store.reload(root)
        check(store.selectedProject?.isStale == true && store.selectedProject?.readmeAvailable == false,
              TestConstants.checkStaleProject)
        try TestConstants.mappedWithoutArchitecture.write(to: projectReadme, atomically: true, encoding: .utf8)
        await store.reload(root)
        check(store.selectedProject?.architecture.isEmpty == true && store.selectedProject?.isStale == false
            && store.selectedProject?.sourceWarning == nil, TestConstants.checkProjectRecovery)
        await store.reload(root.appendingPathComponent(TestConstants.external))
        check(store.syncFailure == nil && store.error != nil && store.selectedProject?.id == project.id,
              TestConstants.checkWrongRootWarning)
        try TestConstants.invalidMappings[0].write(to: readme, atomically: true, encoding: .utf8)
        await store.reload(root)
        check(store.syncFailure != nil && store.selectedProject?.id == project.id, TestConstants.checkStaleRoot)
        try TestConstants.mappedRoot.replacingOccurrences(of: TestConstants.mappedProjectRow,
            with: TestConstants.mappedProjectRow + TestConstants.mappedSecondRow)
            .write(to: readme, atomically: true, encoding: .utf8)
        await store.reload(root)
        check(store.syncFailure == nil && store.snapshot?.projects.count == 2, TestConstants.checkMappedRoot)
        try TestConstants.mappedRoot.replacingOccurrences(of: TestConstants.mappedProjectRow, with: ControlConstants.empty)
            .write(to: readme, atomically: true, encoding: .utf8)
        await store.reload(root)
        check(store.snapshot?.projects.map(\.id) == [project.id] && store.snapshot?.projects.first?.isRegistered == false
            && store.selection == project.id, TestConstants.checkEmptyRegister)
        check(store.notes(for: project.id) == [note], TestConstants.checkSyncNotes)
        try TestConstants.rootReadme.write(to: readme, atomically: true, encoding: .utf8)
        try TestConstants.projectReadme.write(to: projectReadme, atomically: true, encoding: .utf8)
    }

    /// Holds a poll across a repository switch to exercise the main-actor handoff deterministically.
    /// - Parameters:
    ///   - root: Disposable parent.
    ///   - storage: Isolated notes.
    ///   - preferences: Isolated preferences.
    /// - Returns: Nothing; fails if the old poll is queued after the user's newer selection.
    private static func pollingRaceCheck(_ root: URL, storage: WorkspaceStorage, preferences: UserDefaults) async throws {
        let base = root.appendingPathComponent(TestConstants.raceDirectory)
        let oldRoot = base.appendingPathComponent(TestConstants.project)
        let newRoot = base.appendingPathComponent(TestConstants.secondRepository)
        for folder in [oldRoot, newRoot] {
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            try TestConstants.mappedRoot.write(to: folder.appendingPathComponent(ControlConstants.readme), atomically: true, encoding: .utf8)
        }
        let pollStarted = DispatchSemaphore(value: 0)
        let pollRelease = DispatchSemaphore(value: 0)
        let readStarted = DispatchSemaphore(value: 0)
        let readRelease = DispatchSemaphore(value: 0)
        let store = ControlStore(storage: storage, preferences: preferences, fingerprintRepository: { _ in
            pollStarted.signal()
            _ = pollRelease.wait(timeout: .now() + 5)
            return []
        }, readRepository: { url in
            if url == newRoot {
                readStarted.signal()
                _ = readRelease.wait(timeout: .now() + 5)
            }
            return try RepositoryReader.load(url)
        })
        await store.reload(oldRoot)
        let observer = Task { await store.observe() }
        let polling = await withCheckedContinuation { continuation in
            DispatchQueue.global().async { continuation.resume(returning: pollStarted.wait(timeout: .now() + 5) == .success) }
        }
        check(polling, TestConstants.checkPollingRace)
        let switchTask = Task { await store.reload(newRoot) }
        let switching = await withCheckedContinuation { continuation in
            DispatchQueue.global().async { continuation.resume(returning: readStarted.wait(timeout: .now() + 5) == .success) }
        }
        check(switching, TestConstants.checkPollingRace)
        pollRelease.signal()
        try await Task.sleep(for: .milliseconds(250))
        readRelease.signal()
        await switchTask.value
        observer.cancel()
        await observer.value
        check(store.snapshot?.root == newRoot.resolvingSymlinksInPath().standardizedFileURL, TestConstants.checkPollingRace)
    }

    /// Exercises automatic recovery when the remembered root README initially cannot be read.
    /// - Parameters:
    ///   - root: Disposable parent.
    ///   - storage: Isolated notes.
    ///   - preferences: Isolated preferences.
    /// - Returns: Nothing; terminates on a retry-lifecycle regression.
    private static func initialRecoveryCheck(_ root: URL, storage: WorkspaceStorage, preferences: UserDefaults) async throws {
        let repository = root.appendingPathComponent(TestConstants.alias)
        try FileManager.default.createDirectory(at: repository, withIntermediateDirectories: true)
        preferences.set(repository.path, forKey: ControlConstants.folderPreference)
        let store = ControlStore(storage: storage, preferences: preferences)
        await store.reload(repository)
        check(store.snapshot == nil && store.syncFailure != nil, TestConstants.checkInitialRecovery)
        let observer = Task { await store.observe() }
        try TestConstants.mappedRoot.write(to: repository.appendingPathComponent(ControlConstants.readme), atomically: true, encoding: .utf8)
        let deadline = ContinuousClock.now.advanced(by: .seconds(5))
        while store.snapshot == nil && ContinuousClock.now < deadline { try await Task.sleep(for: .milliseconds(50)) }
        observer.cancel()
        await observer.value
        check(store.snapshot?.projects.count == 1 && store.syncFailure == nil, TestConstants.checkInitialRecovery)
    }

    /// Keeps parent and child selections stable across repository refreshes.
    /// - Parameters:
    ///   - root: Disposable repository.
    ///   - storage: Isolated state.
    ///   - preferences: Isolated preferences.
    /// - Returns: Nothing; terminates on a navigation-state regression.
    private static func navigationChecks(_ root: URL, storage: WorkspaceStorage, preferences: UserDefaults) async {
        let store = ControlStore(storage: storage, preferences: preferences)
        await store.reload(root)
        let parent = root.resolvingSymlinksInPath().standardizedFileURL.path
        check(store.selection == parent && store.selectedProject == nil, TestConstants.checkRepositorySelection)
        let child = store.snapshot?.projects.first?.id
        store.selection = child
        await store.reload(root)
        check(child != nil && store.selectedProject?.id == child, TestConstants.checkProjectSelection)
        store.selection = parent
        await store.reload(root)
        check(store.selection == parent && store.selectedProject == nil, TestConstants.checkRepositorySelection)
        store.selection = TestConstants.external
        await store.reload(root)
        check(store.selection == parent, TestConstants.checkSelectionFallback)
    }

    /// Reproduces an edit between snapshot parsing and delivery to the main actor.
    /// - Parameters:
    ///   - root: Disposable repository.
    ///   - storage: Isolated workspace file.
    ///   - preferences: Isolated preference suite.
    /// - Returns: Nothing; fails if polling misses the concurrent edit.
    private static func refreshCheck(_ root: URL, storage: WorkspaceStorage, preferences: UserDefaults) async throws {
        let folder = root.appendingPathComponent(TestConstants.project)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let readme = folder.appendingPathComponent(ControlConstants.readme)
        try TestConstants.projectReadme.write(to: readme, atomically: true, encoding: .utf8)
        let mutation = DispatchSemaphore(value: 0)
        mutation.signal()
        let store = ControlStore(storage: storage, preferences: preferences, readRepository: { url in
            let snapshot = try RepositoryReader.load(url)
            if mutation.wait(timeout: .now()) == .success {
                try TestConstants.updatedReadme.write(to: readme, atomically: true, encoding: .utf8)
            }
            return snapshot
        })
        await store.reload(root)
        let observer = Task { await store.observe() }
        let deadline = ContinuousClock.now.advanced(by: .seconds(5))
        while store.snapshot?.projects.first?.introduction != TestConstants.updatedIntroduction && ContinuousClock.now < deadline {
            try await Task.sleep(for: .milliseconds(50))
        }
        observer.cancel()
        await observer.value
        check(store.snapshot?.projects.first?.introduction == TestConstants.updatedIntroduction, TestConstants.checkConcurrentRefresh)
    }

    /// Checks manual fallback resolution and automatic precedence without executing applications.
    /// - Parameters:
    ///   - root: Disposable repository.
    ///   - storage: Isolated workspace file.
    ///   - preferences: Isolated preference suite.
    /// - Returns: Nothing; fails if launch-target selection changes the safety or fallback contract.
    private static func applicationChecks(_ root: URL, storage: WorkspaceStorage, preferences: UserDefaults) throws {
        var project = try RepositoryReader.load(root).projects[0]
        let manual = try TestFixtures.application(in: root, name: TestConstants.external)
        var state = WorkspaceState()
        state.applications[project.id] = manual.path
        try storage.save(state)
        let store = ControlStore(storage: storage, preferences: preferences)
        check(store.application(for: project) == manual, TestConstants.checkManualApp)
        let automatic = try TestFixtures.application(in: project.folder, name: project.name)
        project.applications = [automatic]
        check(store.application(for: project) == automatic, TestConstants.checkAutomaticApp)
        store.clearApplication(for: project.id)
        check(try storage.load().applications[project.id] == nil && FileManager.default.fileExists(atPath: manual.path), TestConstants.checkClearApp)
        try storage.save(state)
        try FileManager.default.removeItem(at: automatic)
        try FileManager.default.removeItem(at: manual)
        let stale = ControlStore(storage: storage, preferences: preferences)
        check(stale.application(for: project) == nil, TestConstants.checkStaleApp)
    }

    /// Records a deterministic state assertion.
    /// - Parameters:
    ///   - condition: Expected truth value.
    ///   - label: Failure explanation.
    /// - Returns: Nothing; terminates unsuccessfully if the condition is false.
    private static func check(_ condition: Bool, _ label: String) {
        guard condition else { fatalError(TestConstants.failed + label) }
        count += 1
    }
}
