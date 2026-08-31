import Foundation

/// Atomic local persistence; malformed existing data is never silently reset.
internal struct WorkspaceStorage {
    internal let file: URL

    /// Loads saved notes and launch targets, returning an empty state only on first use.
    /// - Returns: The decoded state, or an error preserving the existing file.
    internal func load() throws -> WorkspaceState {
        guard FileManager.default.fileExists(atPath: file.path) else { return WorkspaceState() }
        return try JSONDecoder().decode(WorkspaceState.self, from: Data(contentsOf: file))
    }

    /// Saves a full state atomically before the interface adopts a mutation.
    /// - Parameter state: Proposed local state.
    /// - Returns: Nothing; throws if persistence fails.
    internal func save(_ state: WorkspaceState) throws {
        try FileManager.default.createDirectory(at: file.deletingLastPathComponent(), withIntermediateDirectories: true)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        try encoder.encode(state).write(to: file, options: .atomic)
    }
}
