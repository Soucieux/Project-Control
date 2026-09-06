import Foundation

/// Regression checks for plain-note migration, atomic mutations, and below-tab prose grouping.
@main
@MainActor
internal enum NotesTests {
    private static var count = 0

    /// Exercises isolated local files without reading or modifying the user's notes.
    /// - Returns: Nothing; throws or terminates on an unexpected result.
    internal static func main() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(TestConstants.rootName + UUID().uuidString)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }
        let suite = TestConstants.rootName + UUID().uuidString
        guard let preferences = UserDefaults(suiteName: suite) else { fatalError(NotesTestConstants.storeLabel) }
        defer { preferences.removePersistentDomain(forName: suite) }
        let storage = WorkspaceStorage(file: root.appendingPathComponent(ControlConstants.stateFile))
        try NotesTestConstants.legacy.write(to: storage.file, atomically: true, encoding: .utf8)
        let store = ControlStore(storage: storage, preferences: preferences)
        guard let note = store.notes(for: NotesTestConstants.projectID).first else { fatalError(NotesTestConstants.noteLabel) }
        check(note.text == NotesTestConstants.legacyText && note.isValid, NotesTestConstants.noteLabel)
        check(try String(contentsOf: storage.file, encoding: .utf8) == NotesTestConstants.legacy, NotesTestConstants.noteLabel)
        check(try JSONDecoder().decode(WorkNote.self, from: JSONEncoder().encode(note)) == note, NotesTestConstants.noteLabel)
        let encoded = try JSONSerialization.jsonObject(with: JSONEncoder().encode(note)) as? [String: Any]
        check(encoded?.count == 2, NotesTestConstants.noteLabel)
        check(WorkNote(text: TestConstants.title).isValid, NotesTestConstants.noteLabel)
        check(!WorkNote(text: ControlConstants.space + ControlConstants.newline).isValid, NotesTestConstants.noteLabel)
        let maximum = String(repeating: ControlConstants.pipe, count: ControlConstants.maxNoteLength)
        check(WorkNote(text: maximum).isValid && !WorkNote(text: maximum + ControlConstants.pipe).isValid, NotesTestConstants.noteLabel)
        check(!store.save(WorkNote(text: ControlConstants.space), for: NotesTestConstants.projectID), NotesTestConstants.storeLabel)
        check(store.notes(for: NotesTestConstants.projectID) == [note], NotesTestConstants.storeLabel)
        check(try String(contentsOf: storage.file, encoding: .utf8) == NotesTestConstants.legacy, NotesTestConstants.storeLabel)
        var edited = note
        edited.text += ControlConstants.newline + TestConstants.detail
        check(store.save(edited, for: NotesTestConstants.projectID), NotesTestConstants.storeLabel)
        check(try storage.load().notes[NotesTestConstants.projectID] == [edited] && edited.id == note.id, NotesTestConstants.storeLabel)
        let added = WorkNote(text: TestConstants.title)
        check(store.save(added, for: NotesTestConstants.projectID) && store.notes(for: NotesTestConstants.projectID).count == 2, NotesTestConstants.storeLabel)
        store.delete(added, for: NotesTestConstants.projectID)
        check(try storage.load().notes[NotesTestConstants.projectID] == [edited], NotesTestConstants.storeLabel)
        let blocked = root.appendingPathComponent(TestConstants.blockedFile)
        try TestConstants.corrupt.write(to: blocked, atomically: true, encoding: .utf8)
        let failing = ControlStore(storage: WorkspaceStorage(file: blocked.appendingPathComponent(ControlConstants.stateFile)), preferences: preferences)
        check(!failing.save(note, for: NotesTestConstants.projectID) && failing.notes(for: NotesTestConstants.projectID).isEmpty, NotesTestConstants.storeLabel)
        var duplicates = WorkspaceState()
        duplicates.notes[NotesTestConstants.projectID] = [note, note]
        let duplicateBytes = try JSONEncoder().encode(duplicates)
        try duplicateBytes.write(to: storage.file)
        let duplicateStore = ControlStore(storage: storage, preferences: preferences)
        let duplicateSaveRejected = !duplicateStore.save(note, for: NotesTestConstants.projectID)
        let retainedDuplicateBytes = try Data(contentsOf: storage.file)
        check(!duplicateStore.storageReady && duplicateSaveRejected && retainedDuplicateBytes == duplicateBytes,
            "duplicate note identities preserve the file and disable editing")
        try NotesTestConstants.malformed.write(to: storage.file, atomically: true, encoding: .utf8)
        let locked = ControlStore(storage: storage, preferences: preferences)
        check(!locked.storageReady && !locked.save(note, for: NotesTestConstants.projectID), NotesTestConstants.storeLabel)
        check(try String(contentsOf: storage.file, encoding: .utf8) == NotesTestConstants.malformed, NotesTestConstants.storeLabel)
        contentChecks()
        print(NotesTestConstants.success + String(count))
    }

    /// Covers mixed documents, empty views, bold-only titles, and every registered project's text tabs.
    /// - Returns: Nothing; fails if source order, ownership, or standalone-heading treatment changes.
    private static func contentChecks() {
        let blocks = [ReadmeBlock(kind: .paragraph, text: TestConstants.title),
            ReadmeBlock(kind: .bullet, text: TestConstants.detail),
            ReadmeBlock(kind: .heading, text: TestConstants.title),
            ReadmeBlock(kind: .paragraph, text: TestConstants.detail),
            ReadmeBlock(kind: .table, text: ControlConstants.empty, table: ReadmeTable(headers: [TestConstants.title], rows: [[TestConstants.detail]])),
            ReadmeBlock(kind: .bullet, text: TestConstants.title)]
        let groups = ReadmeBlock.contentGroups(blocks)
        check(groups.map(\.count) == [2, 1, 1, 1, 1], NotesTestConstants.contentLabel)
        check(groups.flatMap { $0 }.map(\.id) == blocks.map(\.id), NotesTestConstants.contentLabel)
        check(ReadmeBlock.contentGroups([]).isEmpty, NotesTestConstants.contentLabel)
        let bold = ReadmeParser.overview(ReadmeParser.sections(NotesTestConstants.boldReadme), fallback: ControlConstants.empty)
        check(bold.map(\.kind) == [.heading, .paragraph], NotesTestConstants.contentLabel)
        do {
            let live = try RepositoryReader.load(URL(fileURLWithPath: TestConstants.liveRoot))
            check(live.projects.count == 6, NotesTestConstants.contentLabel)
            for project in live.projects {
                for blocks in [project.overview, project.architecture, project.models] {
                    let groups = ReadmeBlock.contentGroups(blocks)
                    check(groups.flatMap { $0 }.map(\.id) == blocks.map(\.id)
                        && groups.allSatisfy { group in group.count == 1 || group.allSatisfy { $0.kind == .paragraph || $0.kind == .bullet } }, NotesTestConstants.contentLabel)
                }
            }
        } catch { fatalError(NotesTestConstants.contentLabel) }
    }

    /// Records one deterministic condition with its owning regression label.
    /// - Parameters: condition: Expected truth. label: Failure description.
    /// - Returns: Nothing; terminates on failure.
    private static func check(_ condition: Bool, _ label: String) {
        guard condition else { fatalError(label) }
        count += 1
    }
}
