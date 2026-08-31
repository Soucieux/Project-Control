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
}

/// A complete repository snapshot; refresh failures never replace it with partial data.
internal struct RepositorySnapshot {
    internal let root: URL
    internal let projects: [ProjectRecord]
    internal let history: [HistoryEntry]
    internal let readAt: Date
    internal let fingerprint: [String]
    internal var overview: [ReadmeBlock] = []
}

/// Stable Codable cases; human-readable labels remain centralized.
internal enum WorkStatus: Int, Codable, CaseIterable, Identifiable {
    case next, inProgress, done
    internal var id: Int { rawValue }
    internal var label: String {
        switch self {
        case .next: ControlConstants.next
        case .inProgress: ControlConstants.inProgress
        case .done: ControlConstants.done
        }
    }
}

/// A user-maintained work item, independent of generated README summaries.
internal struct WorkNote: Codable, Identifiable, Equatable {
    internal var id = UUID()
    internal var title: String
    internal var detail: String
    internal var status: WorkStatus
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
