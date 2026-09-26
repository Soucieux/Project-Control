import Foundation

/// Regression checks for plain-note migration, atomic mutations, and below-tab prose grouping.
@main
@MainActor
internal enum NotesTests {
    /// Exercises isolated local files without reading or modifying the user's notes.
    /// - Returns: Nothing; throws or terminates on an unexpected result.
    internal static func main() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(TestConstants.rootName + UUID().uuidString)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }
        // A suite named by a path keeps its plist inside the disposable root, never in ~/Library/Preferences.
        let suite = root.appendingPathComponent(TestConstants.preferencesSuite).path
        guard let preferences = UserDefaults(suiteName: suite) else { fatalError(NotesTestConstants.storeLabel) }
        defer { preferences.removePersistentDomain(forName: suite) }
        let storage = WorkspaceStorage(file: root.appendingPathComponent(ControlConstants.stateFile))
        try NotesTestConstants.legacy.write(to: storage.file, atomically: true, encoding: .utf8)
        let store = ControlStore(storage: storage, preferences: preferences)
        guard let note = store.notes(for: NotesTestConstants.projectID).first else { fatalError(NotesTestConstants.noteLabel) }
        TestSupport.check(note.text == NotesTestConstants.legacyText && note.isValid, NotesTestConstants.noteLabel)
        TestSupport.check(try String(contentsOf: storage.file, encoding: .utf8) == NotesTestConstants.legacy, NotesTestConstants.noteLabel)
        TestSupport.check(try JSONDecoder().decode(WorkNote.self, from: JSONEncoder().encode(note)) == note, NotesTestConstants.noteLabel)
        let encoded = try JSONSerialization.jsonObject(with: JSONEncoder().encode(note)) as? [String: Any]
        TestSupport.check(encoded?.count == 2, NotesTestConstants.noteLabel)
        TestSupport.check(WorkNote(text: TestConstants.title).isValid, NotesTestConstants.noteLabel)
        TestSupport.check(!WorkNote(text: ControlConstants.space + ControlConstants.newline).isValid, NotesTestConstants.noteLabel)
        let maximum = String(repeating: ControlConstants.pipe, count: ControlConstants.maxNoteLength)
        TestSupport.check(WorkNote(text: maximum).isValid && !WorkNote(text: maximum + ControlConstants.pipe).isValid, NotesTestConstants.noteLabel)
        TestSupport.check(!store.save(WorkNote(text: ControlConstants.space), for: NotesTestConstants.projectID), NotesTestConstants.storeLabel)
        TestSupport.check(store.notes(for: NotesTestConstants.projectID) == [note], NotesTestConstants.storeLabel)
        TestSupport.check(try String(contentsOf: storage.file, encoding: .utf8) == NotesTestConstants.legacy, NotesTestConstants.storeLabel)
        var edited = note
        edited.text += ControlConstants.newline + TestConstants.detail
        TestSupport.check(store.save(edited, for: NotesTestConstants.projectID), NotesTestConstants.storeLabel)
        TestSupport.check(try storage.load().notes[NotesTestConstants.projectID] == [edited] && edited.id == note.id, NotesTestConstants.storeLabel)
        let added = WorkNote(text: TestConstants.title)
        TestSupport.check(store.save(added, for: NotesTestConstants.projectID) && store.notes(for: NotesTestConstants.projectID).count == 2, NotesTestConstants.storeLabel)
        store.delete(added, for: NotesTestConstants.projectID)
        TestSupport.check(try storage.load().notes[NotesTestConstants.projectID] == [edited], NotesTestConstants.storeLabel)
        let blocked = root.appendingPathComponent(TestConstants.blockedFile)
        try TestConstants.corrupt.write(to: blocked, atomically: true, encoding: .utf8)
        let failing = ControlStore(storage: WorkspaceStorage(file: blocked.appendingPathComponent(ControlConstants.stateFile)), preferences: preferences)
        TestSupport.check(!failing.save(note, for: NotesTestConstants.projectID) && failing.notes(for: NotesTestConstants.projectID).isEmpty, NotesTestConstants.storeLabel)
        var duplicates = WorkspaceState()
        duplicates.notes[NotesTestConstants.projectID] = [note, note]
        let duplicateBytes = try JSONEncoder().encode(duplicates)
        try duplicateBytes.write(to: storage.file)
        let duplicateStore = ControlStore(storage: storage, preferences: preferences)
        let duplicateSaveRejected = !duplicateStore.save(note, for: NotesTestConstants.projectID)
        let retainedDuplicateBytes = try Data(contentsOf: storage.file)
        TestSupport.check(!duplicateStore.storageReady && duplicateSaveRejected && retainedDuplicateBytes == duplicateBytes,
            "duplicate note identities preserve the file and disable editing")
        try NotesTestConstants.malformed.write(to: storage.file, atomically: true, encoding: .utf8)
        let locked = ControlStore(storage: storage, preferences: preferences)
        TestSupport.check(!locked.storageReady && !locked.save(note, for: NotesTestConstants.projectID), NotesTestConstants.storeLabel)
        TestSupport.check(try String(contentsOf: storage.file, encoding: .utf8) == NotesTestConstants.malformed, NotesTestConstants.storeLabel)
        contentChecks()
        print(NotesTestConstants.success + String(TestSupport.count))
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
        TestSupport.check(groups.map(\.count) == [2, 1, 1, 1, 1], NotesTestConstants.contentLabel)
        TestSupport.check(groups.flatMap { $0 }.map(\.id) == blocks.map(\.id), NotesTestConstants.contentLabel)
        TestSupport.check(ReadmeBlock.contentGroups([]).isEmpty, NotesTestConstants.contentLabel)
        let bold = ReadmeParser.overview(ReadmeParser.sections(NotesTestConstants.boldReadme), fallback: ControlConstants.empty)
        TestSupport.check(bold.map(\.kind) == [.heading, .paragraph], NotesTestConstants.contentLabel)
        do {
            let live = try RepositoryReader.load(URL(fileURLWithPath: TestConstants.liveRoot))
            let register = try TestFixtures.registerRows(in: URL(fileURLWithPath: TestConstants.liveRoot))
            TestSupport.check(live.projects.filter(\.isRegistered).map(\.name) == register.map(\.name), NotesTestConstants.contentLabel)
            for project in live.projects {
                for blocks in [project.overview, project.architecture, project.models] {
                    let groups = ReadmeBlock.contentGroups(blocks)
                    TestSupport.check(groups.flatMap { $0 }.map(\.id) == blocks.map(\.id)
                        && groups.allSatisfy { group in group.count == 1 || group.allSatisfy { $0.kind == .paragraph || $0.kind == .bullet } }, NotesTestConstants.contentLabel)
                }
            }
        } catch { fatalError(NotesTestConstants.contentLabel) }
    }
}
