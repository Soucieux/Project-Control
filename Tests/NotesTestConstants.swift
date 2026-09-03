import Foundation

/// Fixtures and labels for plain-note migration and presentation regressions.
internal enum NotesTestConstants {
    internal static let legacy = #"{"notes":{"project":[{"id":"77E06C71-911B-4D6E-B82D-0645803B0452","title":"Keep this title","detail":"First line\nSecond line ☀️","status":2}]},"applications":{}}"#
    internal static let legacyText = "Keep this title\n\nFirst line\nSecond line ☀️"
    internal static let projectID = "project"
    internal static let malformed = #"{"notes":{"project":[{"id":"77E06C71-911B-4D6E-B82D-0645803B0452","text":null}]},"applications":{}}"#
    internal static let boldReadme = "## Overview\n\n**Standalone title**\n\nOrdinary **emphasized** prose."
    internal static let noteLabel = "Plain-note migration and validation"
    internal static let storeLabel = "Atomic note save, edit, delete, and failure preservation"
    internal static let contentLabel = "Prose grouping preserves headings, tables, and source order"
    internal static let success = "Notes/presentation checks passed: "
}
