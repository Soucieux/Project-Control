import Foundation

/// Focused executable checks, intentionally independent of the UI and other subprojects.
@main
internal enum CoreTests {
    private static var count = 0

    /// Checks parser, local storage, refresh, and path boundaries with disposable fixtures.
    /// - Returns: Nothing; exits unsuccessfully on the first failed check or thrown error.
    internal static func main() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(TestConstants.rootName + UUID().uuidString)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }
        let repository = root.appendingPathComponent(ControlConstants.appName)
        let project = repository.appendingPathComponent(TestConstants.project)
        try FileManager.default.createDirectory(at: project, withIntermediateDirectories: true)
        let rootReadme = repository.appendingPathComponent(ControlConstants.readme)
        let projectReadme = project.appendingPathComponent(ControlConstants.readme)
        try TestConstants.rootReadme.write(to: rootReadme, atomically: true, encoding: .utf8)
        try TestConstants.projectReadme.write(to: projectReadme, atomically: true, encoding: .utf8)
        let snapshot = try RepositoryReader.load(repository)
        let record = snapshot.projects[0]
        check(snapshot.projects.count == 2, TestConstants.checkRegister)
        check(record.introduction == TestConstants.introduction, TestConstants.checkIntro)
        check(record.version == TestConstants.version, TestConstants.checkVersion)
        check(record.architecture.contains(TestConstants.architecture), TestConstants.checkArchitecture)
        check(record.workflows.count == 2 && record.workflows[0].steps.count == 3, TestConstants.checkRoutes)
        check(!ReadmeParser.sections(TestConstants.projectReadme).flatMap(\.lines).joined().contains(TestConstants.forbidden), TestConstants.checkCode)
        check(record.history.first?.detail == TestConstants.history, TestConstants.checkHistory)
        check(snapshot.history.count == 1 && snapshot.history[0].title == TestConstants.project, TestConstants.checkRootHistory)
        check(!snapshot.projects[1].readmeAvailable && !snapshot.projects[1].folderAvailable, TestConstants.checkMissing)
        let fingerprint = RepositoryReader.fingerprint(snapshot)
        try TestConstants.updatedReadme.write(to: projectReadme, atomically: true, encoding: .utf8)
        check(RepositoryReader.fingerprint(snapshot) != fingerprint, TestConstants.checkChange)
        check(RepositoryReader.fingerprint(snapshot) != snapshot.fingerprint, TestConstants.checkCaptured)
        check(try RepositoryReader.load(repository).projects[0].introduction == TestConstants.updatedIntroduction, TestConstants.checkReload)
        try storageChecks(root)
        try TestConstants.escapedRoot.write(to: rootReadme, atomically: true, encoding: .utf8)
        checkThrows(TestConstants.checkEscape) { _ = try RepositoryReader.load(repository) }
        try TestConstants.symlinkRoot.write(to: rootReadme, atomically: true, encoding: .utf8)
        let outside = root.appendingPathComponent(TestConstants.external)
        try TestConstants.projectReadme.write(to: outside, atomically: true, encoding: .utf8)
        try FileManager.default.removeItem(at: projectReadme)
        try FileManager.default.createSymbolicLink(at: projectReadme, withDestinationURL: outside)
        check(try !RepositoryReader.load(repository).projects[0].readmeAvailable, TestConstants.checkSymlink)
        check(ReadmeParser.sections(TestConstants.tildeCode).count == 3, TestConstants.checkTilde)
        parserChecks()
        try aliasChecks(repository, project: project, outside: outside)
        let live = try RepositoryReader.load(URL(fileURLWithPath: TestConstants.liveRoot))
        check(live.projects.count == 6, TestConstants.checkLive)
        check(live.projects.first { $0.name == TestConstants.liveProject }?.workflows.count == 5, TestConstants.checkLiveFlows)
        print(TestConstants.passed + String(count))
    }

    /// Covers valid Markdown edge cases that previously exposed or truncated content.
    /// - Returns: Nothing; terminates if a parser regression is detected.
    private static func parserChecks() {
        check(!ReadmeParser.sections(TestConstants.misleadingFence).flatMap(\.lines).joined().contains(TestConstants.forbidden), TestConstants.checkFenceSuffix)
        check(ReadmeParser.table(TestConstants.pipeRows).first?.last == TestConstants.pipeValue, TestConstants.checkPipes)
        let flows = ReadmeParser.workflows(ReadmeParser.sections(TestConstants.colonFlows))
        check(flows.first?.steps == [TestConstants.urlStep, TestConstants.resultStep], TestConstants.checkColons)
        check(flows.last?.label == TestConstants.flowLabel, TestConstants.checkLabel)
    }

    /// Checks canonical project identities, alias retargeting, and root README boundaries.
    /// - Parameters: repository: Disposable repository. project: Its real project folder. outside: External fixture file.
    /// - Returns: Nothing; throws on fixture setup failure.
    private static func aliasChecks(_ repository: URL, project: URL, outside: URL) throws {
        let alias = repository.appendingPathComponent(TestConstants.alias)
        let rootReadme = repository.appendingPathComponent(ControlConstants.readme)
        try FileManager.default.createSymbolicLink(at: alias, withDestinationURL: project)
        try TestConstants.aliasRoot.write(to: rootReadme, atomically: true, encoding: .utf8)
        let snapshot = try RepositoryReader.load(repository)
        check(snapshot.projects.count == 1 && snapshot.projects[0].id == project.resolvingSymlinksInPath().path, TestConstants.checkAlias)
        let aliasRecord = ProjectRecord(id: project.path, name: TestConstants.alias, folder: alias,
            readme: alias.appendingPathComponent(ControlConstants.readme), introduction: ControlConstants.empty,
            version: nil, architecture: [], workflows: [], history: [], folderAvailable: true, readmeAvailable: false)
        let aliasSnapshot = RepositorySnapshot(root: repository, projects: [aliasRecord], history: [], readAt: Date(), fingerprint: [])
        let before = RepositoryReader.fingerprint(aliasSnapshot)
        try FileManager.default.removeItem(at: alias)
        try FileManager.default.createSymbolicLink(at: alias, withDestinationURL: outside)
        check(RepositoryReader.fingerprint(aliasSnapshot) != before, TestConstants.checkAliasChange)
        try FileManager.default.removeItem(at: rootReadme)
        try FileManager.default.createSymbolicLink(at: rootReadme, withDestinationURL: outside)
        check(!RepositoryReader.contains(rootReadme, in: repository), TestConstants.checkRootSymlink)
    }

    /// Exercises first-use, round-trip, and corruption behavior without touching user data.
    /// - Parameter root: Disposable directory created by this test process.
    /// - Returns: Nothing; throws on unexpected filesystem failures.
    private static func storageChecks(_ root: URL) throws {
        let storage = WorkspaceStorage(file: root.appendingPathComponent(ControlConstants.stateFile))
        check(try storage.load().notes.isEmpty, TestConstants.checkEmpty)
        var state = WorkspaceState()
        let note = WorkNote(title: TestConstants.title, detail: TestConstants.detail, status: .done)
        state.notes[TestConstants.project] = [note]
        try storage.save(state)
        check(try storage.load().notes[TestConstants.project] == [note], TestConstants.checkNotes)
        try TestConstants.corrupt.write(to: storage.file, atomically: true, encoding: .utf8)
        checkThrows(TestConstants.checkCorrupt) { _ = try storage.load() }
    }

    /// Records a single deterministic assertion.
    /// - Parameters: condition: Expected truth value. label: Failure explanation.
    /// - Returns: Nothing; terminates unsuccessfully on failure.
    private static func check(_ condition: Bool, _ label: String) {
        guard condition else { fatalError(TestConstants.failed + label) }
        count += 1
    }

    /// Asserts that an operation rejects invalid input.
    /// - Parameters: label: Failure explanation. action: Expected throwing operation.
    /// - Returns: Nothing; terminates if no error is raised.
    private static func checkThrows(_ label: String, action: () throws -> Void) {
        do { try action(); check(false, label) }
        catch { count += 1 }
    }
}
