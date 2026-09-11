import Foundation

/// Disposable app metadata fixtures shared by core and store checks; never launched.
internal enum TestFixtures {
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
        try FileManager.default.setAttributes([.posixPermissions: 0o700], ofItemAtPath: executable.path)
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
        process.arguments = ["-C", folder.path, "-c", "core.hooksPath=/dev/null",
            "-c", "commit.gpgSign=false", "-c", "user.name=Fixture",
            "-c", "user.email=fixture@example.invalid"] + arguments
        process.environment = ["PATH": "/usr/bin:/bin", "GIT_CONFIG_NOSYSTEM": "1",
            "GIT_CONFIG_GLOBAL": "/dev/null", "GIT_AUTHOR_DATE": "2024-01-15T12:00:00Z",
            "GIT_COMMITTER_DATE": "2024-01-15T12:00:00Z"]
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice
        try process.run()
        process.waitUntilExit()
        guard process.terminationStatus == 0 else {
            throw ControlFailure(message: "Disposable Git activity fixture could not be created.")
        }
    }
}
