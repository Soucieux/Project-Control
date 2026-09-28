import Foundation

/// One project row of the live root README register, read independently of the app's parser.
internal struct RegisterRow: Equatable {
    internal let name: String
    internal let category: String
    internal let technologies: [String]
}

/// Fixtures and readers the suites share: the live register read independently of the app's parser,
/// flattened legacy text, disposable app bundles that are never launched, and isolated Git fixtures.
internal enum TestFixtures {
    /// Reads the live register's project rows with a deliberately simple scan, so live checks follow
    /// the register as projects are added instead of repeating counts that go stale.
    /// - Parameter root: Repository root holding the register README.
    /// - Returns: Local project rows in register order; a row linking to another repository is skipped.
    ///   Throws when the register README cannot be read as UTF-8 text.
    internal static func registerRows(in root: URL) throws -> [RegisterRow] {
        let readme = try String(contentsOf: root.appendingPathComponent(ControlConstants.readme), encoding: .utf8)
        return readme.components(separatedBy: .newlines).compactMap { line in
            guard line.hasPrefix(TestConstants.registerRowPrefix),
                  let link = line.range(of: TestConstants.registerLinkSeparator),
                  let close = line[link.upperBound...].firstIndex(of: ")"),
                  !line[link.upperBound..<close].contains(TestConstants.externalLinkMarker) else { return nil }
            let name = line[line.index(line.startIndex, offsetBy: TestConstants.registerRowPrefix.count)..<link.lowerBound]
            let technologies = registerValue(TestConstants.registerTechnologiesLabel, in: line).components(separatedBy: ";")
            return RegisterRow(name: String(name), category: registerValue(TestConstants.registerCategoryLabel, in: line),
                technologies: technologies.map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty })
        }
    }

    /// Reads one labelled list item from a register row.
    /// - Parameters:
    ///   - label: Bold label that opens the item.
    ///   - line: One register table row.
    /// - Returns: The item's trimmed text with code-span backticks removed, as the app displays it, or
    ///   an empty string when the row omits the label.
    private static func registerValue(_ label: String, in line: String) -> String {
        guard let start = line.range(of: label),
              let end = line[start.upperBound...].range(of: TestConstants.registerItemEnd) else { return ControlConstants.empty }
        return line[start.upperBound..<end.lowerBound].replacingOccurrences(of: "`", with: ControlConstants.empty)
            .trimmingCharacters(in: .whitespaces)
    }

    /// Flattens parsed blocks only for legacy text assertions; production views retain table structure.
    /// - Parameter blocks: Parsed README presentation blocks.
    /// - Returns: Source prose and joined table rows in their original order.
    internal static func text(_ blocks: [ReadmeBlock]) -> [String] {
        blocks.flatMap { block in
            block.table?.rows.map { $0.joined(separator: ControlConstants.joined) } ?? [block.text]
        }
    }

    /// Creates a synthetic app with valid bundle metadata and an executable placeholder.
    /// - Parameters:
    ///   - folder: Disposable parent directory.
    ///   - name: App filename without its extension.
    /// - Returns: The created bundle URL, or throws on fixture setup failure.
    internal static func application(in folder: URL, name: String) throws -> URL {
        let application = folder.appendingPathComponent(name).appendingPathExtension(ControlConstants.appExtension)
        let contents = application.appendingPathComponent(ControlConstants.appContents)
        let executableFolder = contents.appendingPathComponent(ControlConstants.appExecutableFolder)
        try FileManager.default.createDirectory(at: executableFolder, withIntermediateDirectories: true)
        let metadata = [ControlConstants.bundleTypeKey: ControlConstants.bundleApplicationType,
            ControlConstants.bundleExecutableKey: TestConstants.executableName,
            TestConstants.identifierKey: TestConstants.testBundlePrefix + UUID().uuidString]
        try PropertyListSerialization.data(fromPropertyList: metadata, format: .xml, options: 0)
            .write(to: contents.appendingPathComponent(ControlConstants.appInfo))
        let executable = executableFolder.appendingPathComponent(TestConstants.executableName)
        try TestConstants.fixtureExecutable.write(to: executable, atomically: true, encoding: .utf8)
        try FileManager.default.setAttributes([.posixPermissions: TestConstants.executablePermissions], ofItemAtPath: executable.path)
        return application.resolvingSymlinksInPath().standardizedFileURL
    }

    /// Runs a fixed Git fixture operation with isolated configuration, identity, hooks, and dates.
    /// - Parameters:
    ///   - arguments: Test-owned Git arguments.
    ///   - folder: Disposable fixture directory.
    /// - Returns: Nothing; throws when fixture creation fails.
    internal static func git(_ arguments: [String], in folder: URL) throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: ControlConstants.gitExecutable)
        process.arguments = [ControlConstants.gitCurrentDirectory, folder.path, "-c", "core.hooksPath=/dev/null",
            "-c", "commit.gpgSign=false", "-c", "user.name=Fixture",
            "-c", "user.email=fixture@example.invalid"] + arguments
        process.environment = [ControlConstants.pathEnvironment: ControlConstants.gitSearchPath,
            ControlConstants.gitNoSystemConfigEnvironment: ControlConstants.gitEnvironmentEnabled,
            ControlConstants.gitGlobalConfigEnvironment: ControlConstants.gitNoConfigFile,
            "GIT_AUTHOR_DATE": TestConstants.gitFixtureDate, "GIT_COMMITTER_DATE": TestConstants.gitFixtureDate]
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice
        try process.run()
        process.waitUntilExit()
        guard process.terminationStatus == 0 else {
            throw ControlFailure(message: TestConstants.gitFixtureFailure)
        }
    }
}

/// Counts every suite's deterministic assertions and owns each run's disposable folder and preference suite.
/// A failed assertion removes both before it terminates the run with its label, because the trap skips the
/// suite's `defer`.
internal enum TestSupport {
    internal private(set) static var count = 0
    /// The run's UUID-named folder in the per-user temporary directory, until it is removed.
    private static var folder: URL?
    /// The preference suite opened inside `folder`, with the path that names it.
    private static var suite: (path: String, defaults: UserDefaults)?

    /// Creates the run's disposable folder, which `removeTemporaryFolder()` or a failed check removes.
    /// - Returns: The new folder; throws when it cannot be created.
    internal static func temporaryFolder() throws -> URL {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(TestConstants.rootName + UUID().uuidString)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        folder = root
        return root
    }

    /// Opens a preference suite named by a path inside the run's folder, so its plist stays there; a plain
    /// name would leave an empty file in `~/Library/Preferences` after every run, even once the domain is
    /// removed.
    /// - Parameter root: The run's disposable folder.
    /// - Returns: The isolated suite; ends the run through `fail(_:)` when it cannot be opened.
    internal static func preferences(in root: URL) -> UserDefaults {
        let path = root.appendingPathComponent(TestConstants.preferencesSuite).path
        guard let defaults = UserDefaults(suiteName: path) else { fail(TestConstants.checkPreferencesSuite) }
        suite = (path, defaults)
        return defaults
    }

    /// Clears the run's preference suite and removes its folder.
    /// - Returns: Nothing; a suite or folder already removed is skipped.
    internal static func removeTemporaryFolder() {
        if let suite { suite.defaults.removePersistentDomain(forName: suite.path) }
        if let folder { try? FileManager.default.removeItem(at: folder) }
        suite = nil
        folder = nil
    }

    /// Ends the run unsuccessfully, removing its folder and preference suite first.
    /// - Parameter label: Failure explanation.
    /// - Returns: Never; terminates the run with the label after the cleanup.
    internal static func fail(_ label: String) -> Never {
        removeTemporaryFolder()
        fatalError(TestConstants.failed + label)
    }

    /// Records one assertion.
    /// - Parameters:
    ///   - condition: Expected truth value.
    ///   - label: Failure explanation.
    /// - Returns: Nothing; ends the run through `fail(_:)` when the condition is false.
    internal static func check(_ condition: Bool, _ label: String) {
        guard condition else { fail(label) }
        count += 1
    }

    /// Asserts that an operation rejects invalid input.
    /// - Parameters:
    ///   - label: Failure explanation.
    ///   - action: Expected throwing operation.
    /// - Returns: Nothing; terminates if no error is raised.
    internal static func checkThrows(_ label: String, action: () throws -> Void) {
        do { try action(); check(false, label) }
        catch { count += 1 }
    }
}
