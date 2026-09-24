import Foundation

/// Converts only explicit arrow routes and a bounded text-diagram grammar into directed graphs.
internal enum WorkflowParser {
    /// Converts one horizontal route, preserving its optional source label.
    /// - Parameters:
    ///   - line: README prose line.
    ///   - label: Owning section title.
    /// - Returns: A linear graph, or nil when no complete route is documented.
    internal static func linear(_ line: String, label: String) -> WorkflowRoute? {
        let text = ReadmeParser.plain(line).replacingOccurrences(of: ControlConstants.asciiArrow, with: ControlConstants.arrow)
        guard text.contains(ControlConstants.arrow), !text.hasPrefix(ControlConstants.pipe) else { return nil }
        var name = label
        var route = text
        if let candidate = ReadmeParser.match(text, ControlConstants.workflowLabelPattern, group: 1),
           !candidate.contains(ControlConstants.arrow),
           let content = ReadmeParser.match(text, ControlConstants.workflowLabelPattern, group: 2) {
            name = candidate
            route = content
        }
        let steps = route.components(separatedBy: ControlConstants.arrow).map(ReadmeParser.plain)
        guard steps.count > 1, steps.count <= ControlConstants.maxDiagramNodes, steps.allSatisfy({ !$0.isEmpty }) else { return nil }
        let nodes = steps.enumerated().map { WorkflowNode(id: $0.offset, label: $0.element, layer: $0.offset) }
        let edges = (1..<nodes.count).map { WorkflowEdge(source: $0 - 1, target: $0) }
        return WorkflowRoute(label: name, nodes: nodes, edges: edges)
    }

    /// Reads each blank-line-separated group of a text block as its own routes, so one block can hold
    /// several titled routes.
    /// - Parameters:
    ///   - lines: Text-only fenced block.
    ///   - label: Owning section title, used by a route that has no title line.
    /// - Returns: Complete supported graphs; a malformed or code-like group produces no diagram.
    internal static func diagrams(_ lines: [String], label: String) -> [WorkflowRoute] {
        var groups: [[String]] = [[]]
        for line in lines.map({ $0.replacingOccurrences(of: ControlConstants.asciiArrow, with: ControlConstants.arrow) }) {
            if !line.trimmingCharacters(in: .whitespaces).isEmpty { groups[groups.count - 1].append(line) }
            else if !(groups.last?.isEmpty ?? true) { groups.append([]) }
        }
        return groups.filter { !$0.isEmpty }.flatMap { routes(in: $0, label: label) }
    }

    /// Accepts independent horizontal arrows, or one vertical route with an optional title line,
    /// downward stages, same-depth branch groups, and merges.
    /// - Parameters:
    ///   - group: Consecutive nonblank lines of one text block.
    ///   - label: Name for a vertical route without a title line.
    /// - Returns: The group's graphs, or none when it is malformed or code-like.
    private static func routes(in group: [String], label: String) -> [WorkflowRoute] {
        guard group.count <= ControlConstants.maxDiagramNodes * 2,
              group.allSatisfy({ ReadmeParser.match($0, ControlConstants.unsafeDiagramPattern) == nil }) else { return [] }
        let routes = group.compactMap {
            ReadmeParser.match($0, ControlConstants.branchPattern) == nil ? linear($0, label: label) : nil
        }
        if routes.count == group.count { return routes }
        var source = group
        var name = label
        if source.count > 1, isStage(source[0]), isStage(source[1]) { name = ReadmeParser.plain(source.removeFirst()) }
        var nodes: [WorkflowNode] = []
        var edges: [WorkflowEdge] = []
        var frontier: [Int] = []
        var branches: [Int] = []
        var branchIndent: Int?
        var branchClosed = false
        var connector = false
        for line in source {
            if ReadmeParser.match(line, ControlConstants.downwardPattern) != nil {
                guard !nodes.isEmpty, !connector, branches.isEmpty || branchClosed else { return [] }
                if !branches.isEmpty { frontier = branches; branches = []; branchIndent = nil; branchClosed = false }
                connector = true
                continue
            }
            if let text = ReadmeParser.match(line, ControlConstants.branchPattern, group: 3),
               let marker = ReadmeParser.match(line, ControlConstants.branchPattern, group: 2),
               let indent = ReadmeParser.match(line, ControlConstants.branchPattern, group: 1) {
                guard frontier.count == 1, !connector, !branchClosed,
                      branchIndent == nil || branchIndent == indent.count else { return [] }
                branchIndent = indent.count
                let id = nodes.count
                nodes.append(WorkflowNode(id: id, label: ReadmeParser.plain(text), layer: nodes[frontier[0]].layer + 1))
                edges.append(WorkflowEdge(source: frontier[0], target: id))
                branches.append(id)
                branchClosed = marker == ControlConstants.finalBranch
                continue
            }
            let text = ReadmeParser.plain(line)
            guard !text.isEmpty, !text.contains(ControlConstants.arrow),
                  !text.contains(ControlConstants.asciiArrow), nodes.isEmpty || connector else { return [] }
            let id = nodes.count
            let layer = (frontier.map { nodes[$0].layer }.max() ?? -1) + 1
            nodes.append(WorkflowNode(id: id, label: text, layer: layer))
            edges += frontier.map { WorkflowEdge(source: $0, target: id) }
            frontier = [id]
            connector = false
        }
        guard !edges.isEmpty, !connector, branches.isEmpty || branchClosed,
              nodes.count <= ControlConstants.maxDiagramNodes else { return [] }
        return [WorkflowRoute(label: name, nodes: nodes, edges: edges)]
    }

    /// Recognizes a plain stage line, so two in a row mark the first as a route title.
    /// - Parameter line: One nonblank line of a group.
    /// - Returns: False for a downward connector, a branch, or an arrow route.
    private static func isStage(_ line: String) -> Bool {
        ReadmeParser.match(line, ControlConstants.downwardPattern) == nil && !line.contains(ControlConstants.arrow)
    }
}
