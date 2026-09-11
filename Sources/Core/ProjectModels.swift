import Foundation

/// One Markdown section, without fenced source blocks.
internal struct ReadmeSection {
    internal let title: String
    internal let level: Int
    internal var lines: [String]
    internal var diagrams: [[String]] = []
    internal var mapping: ReadmeTopic? = nil
    internal var mappingInvalid = false
}

/// Allowed README destinations; comments select data, never executable instructions.
internal enum ReadmeTopic { case overview, architecture, models, workflows, history, projects, release, ignore }

/// A readable README block, never raw Markdown or source code.
internal struct ReadmeBlock: Identifiable {
    internal enum Kind { case paragraph, bullet, heading, table }
    internal let id = UUID()
    internal let kind: Kind
    internal let text: String
    internal var table: ReadmeTable? = nil

    /// Groups adjacent prose without enclosing standalone headings or already surfaced tables.
    /// - Parameter blocks: Display blocks in their original README order.
    /// - Returns: Nonempty groups, with each heading and table occupying its own group.
    internal static func contentGroups(_ blocks: [ReadmeBlock]) -> [[ReadmeBlock]] {
        var groups: [[ReadmeBlock]] = []
        for block in blocks {
            if (block.kind == .paragraph || block.kind == .bullet),
               let previous = groups.last?.last, previous.kind == .paragraph || previous.kind == .bullet {
                groups[groups.count - 1].append(block)
            } else {
                groups.append([block])
            }
        }
        return groups
    }
}

/// Source column headings and data rows, kept separate from Markdown delimiters.
internal struct ReadmeTable {
    internal let headers: [String]
    internal let rows: [[String]]
}

/// Stable tab identities keep content ownership separate from presentation order.
internal enum ProjectTab: Int, CaseIterable, Identifiable {
    case overview, architecture, models, workflows, notes, history
    internal var id: Int { rawValue }
    internal var label: String {
        switch self {
        case .overview: ControlConstants.overview
        case .architecture: ControlConstants.architecture
        case .models: ControlConstants.models
        case .workflows: ControlConstants.workflow
        case .notes: ControlConstants.notes
        case .history: ControlConstants.history
        }
    }
}

/// Stable repository tab identities keep README content and Git activity visibly separate.
internal enum RepositoryTab: Int, CaseIterable, Identifiable {
    case overview, history, activity
    internal var id: Int { rawValue }
    internal var label: String {
        switch self {
        case .overview: ControlConstants.overview
        case .history: ControlConstants.repositoryHistory
        case .activity: ControlConstants.commitActivity
        }
    }
}

/// One source-labelled node at an explicit depth in a workflow.
internal struct WorkflowNode: Identifiable {
    internal let id: Int
    internal let label: String
    internal let layer: Int
}

/// A directed connection between two source-defined workflow nodes.
internal struct WorkflowEdge: Equatable {
    internal let source: Int
    internal let target: Int
}

/// A labelled graph derived only from arrows written in a README.
internal struct WorkflowRoute: Identifiable {
    internal let id = UUID()
    internal let label: String
    internal let nodes: [WorkflowNode]
    internal let edges: [WorkflowEdge]
    internal var steps: [String] { nodes.map(\.label) }
}

/// A source-labelled release or changelog entry.
internal struct HistoryEntry: Identifiable {
    internal let id = UUID()
    internal let title: String
    internal let detail: String
    internal var date: String? = nil
    internal var heading: String { title + (date.map { ControlConstants.joined + $0 } ?? ControlConstants.empty) }
}

/// Explicit register metadata, independent of a project's purpose, code, or runtime health.
internal struct ProjectClassification: Equatable {
    internal var category: String = ControlConstants.uncategorized
    internal var technicalScope: String? = nil
    internal var technologies: [String] = []
}

/// One source-ordered sidebar category; membership never changes a project's path identity.
internal struct ProjectCategory: Identifiable {
    internal let name: String
    internal var projects: [ProjectRecord]
    internal var id: String { name }
}

/// Twelve source-derived commit counts for one valid calendar year.
internal struct CommitActivityYear: Identifiable, Equatable {
    internal let year: Int
    internal let months: [Int]
    internal var projectCounts: [[String: Int]] = []
    internal var id: Int { year }
}

/// One local Git record containing only its timestamp and mapped project identities.
internal struct GitCommitMetadata: Equatable {
    internal let timestamp: String
    internal let projectIDs: Set<String>
}

/// Complete loaded Git activity; totals remain independent from valid monthly buckets.
internal struct CommitActivity: Equatable {
    internal let years: [CommitActivityYear]
    internal let totalCount: Int
    internal let available: Bool
    internal var yearCount: Int { years.count }
    internal static let unavailable = CommitActivity(years: [], totalCount: 0, available: false)
}

/// Read-only, display-ready information for a project registered in the root README.
internal struct ProjectRecord: Identifiable {
    internal let id: String
    internal var name: String
    internal let folder: URL
    internal let readme: URL
    internal let introduction: String
    internal let version: String?
    internal let architecture: [ReadmeBlock]
    internal let workflows: [WorkflowRoute]
    internal let history: [HistoryEntry]
    internal var folderAvailable: Bool
    internal var readmeAvailable: Bool
    internal var overview: [ReadmeBlock] = []
    internal var models: [ReadmeBlock] = []
    internal var applications: [URL] = []
    internal var sourceWarning: String? = nil
    internal var isStale = false
    internal var classification = ProjectClassification()
}

/// A complete repository snapshot; refresh failures never replace it with partial data.
internal struct RepositorySnapshot {
    internal let root: URL
    internal let projects: [ProjectRecord]
    internal let history: [HistoryEntry]
    internal let readAt: Date
    internal let fingerprint: [String]
    internal var overview: [ReadmeBlock] = []
    internal var commitActivity: CommitActivity = .unavailable

    internal var categories: [ProjectCategory] {
        var groups: [ProjectCategory] = []
        for project in projects {
            let name = project.classification.category
            if let index = groups.firstIndex(where: { $0.name == name }) {
                groups[index].projects.append(project)
            } else {
                groups.append(ProjectCategory(name: name, projects: [project]))
            }
        }
        return groups
    }
}

/// A plain-text note; legacy title and context remain readable without status tracking.
internal struct WorkNote: Codable, Identifiable, Equatable {
    internal let id: UUID
    internal var text: String
    internal var isValid: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && text.count <= ControlConstants.maxNoteLength
    }
    private enum CodingKeys: String, CodingKey { case id, text, title, detail }

    /// Creates a plain note while allowing edits to retain the saved identity.
    /// - Parameters:
    ///   - id: Existing identity, or a new one for an unsaved note.
    ///   - text: Complete note content.
    /// - Returns: A plain-text work note with the supplied identity.
    internal init(id: UUID = UUID(), text: String) { self.id = id; self.text = text }

    /// Reads current notes or joins legacy title/context without modifying the saved file.
    /// - Parameter decoder: Local workspace decoder.
    /// - Returns: A current-format note containing all retained legacy text when applicable.
    /// - Throws: A decoding error for malformed or incomplete note data.
    internal init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(UUID.self, forKey: .id)
        if values.contains(.text) {
            text = try values.decode(String.self, forKey: .text)
        } else {
            let title = try values.decode(String.self, forKey: .title)
            let detail = try values.decode(String.self, forKey: .detail)
            text = [title, detail].filter { !$0.isEmpty }.joined(separator: ControlConstants.newline + ControlConstants.newline)
        }
    }

    /// Stores only the stable identity and complete plain-text content on the next authorized save.
    /// - Parameter encoder: Atomic workspace-save encoder.
    /// - Returns: Nothing; supplies the note's fields to the encoder.
    /// - Throws: An encoding error when the encoder cannot represent the note.
    internal func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try values.encode(id, forKey: .id)
        try values.encode(text, forKey: .text)
    }
}

/// Local settings and notes keyed by canonical project path, not display name.
internal struct WorkspaceState: Codable {
    internal var notes: [String: [WorkNote]] = [:]
    internal var applications: [String: String] = [:]
}

/// User-facing failures that do not expose source contents.
internal struct ControlFailure: LocalizedError {
    internal let message: String
    internal var errorDescription: String? { message }
}
