import Foundation

/// A deliberately limited Markdown extractor, not an HTML renderer or code viewer.
internal enum ReadmeParser {
    /// Replaces regular-expression matches with plain text.
    /// - Parameters: value: Input text. pattern: Trusted expression. replacement: Replacement template.
    /// - Returns: The transformed text.
    internal static func replace(_ value: String, _ pattern: String, _ replacement: String) -> String {
        value.replacingOccurrences(of: pattern, with: replacement, options: .regularExpression)
    }

    /// Extracts a capture group from the first expression match.
    /// - Parameters: value: Input text. pattern: Trusted expression. group: Capture index.
    /// - Returns: Matched text, or nil when absent.
    internal static func match(_ value: String, _ pattern: String, group: Int = 0) -> String? {
        guard let expression = try? NSRegularExpression(pattern: pattern),
              let result = expression.firstMatch(in: value, range: NSRange(value.startIndex..., in: value)),
              let range = Range(result.range(at: group), in: value) else { return nil }
        return String(value[range])
    }

    /// Removes presentation markup without evaluating HTML, links, or inline code.
    /// - Parameter value: A Markdown fragment.
    /// - Returns: Noninteractive readable text.
    internal static func plain(_ value: String) -> String {
        var result = replace(value, ControlConstants.linkPattern, ControlConstants.linkLabelReplacement)
        result = replace(result, ControlConstants.htmlBreakPattern, ControlConstants.space)
        result = replace(result, ControlConstants.htmlPattern, ControlConstants.empty)
        result = replace(result, ControlConstants.markupPattern, ControlConstants.empty)
        return replace(result, ControlConstants.whitespacePattern, ControlConstants.space)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Splits a document at headings and excludes fenced blocks entirely.
    /// - Parameter markdown: UTF-8 README contents.
    /// - Returns: Ordered sections preserving their source headings.
    internal static func sections(_ markdown: String) -> [ReadmeSection] {
        var result = [ReadmeSection(title: ControlConstants.empty, lines: [])]
        var fence: String?
        for line in markdown.components(separatedBy: .newlines) {
            if let marker = match(line, ControlConstants.fencePattern, group: 1) {
                if let current = fence {
                    if marker.first == current.first && marker.count >= current.count,
                       match(line, ControlConstants.closingFencePattern) != nil { fence = nil }
                } else { fence = marker }
                continue
            }
            guard fence == nil else { continue }
            if let heading = match(line, ControlConstants.headingPattern, group: 2) {
                result.append(ReadmeSection(title: plain(heading), lines: []))
            } else {
                result[result.count - 1].lines.append(line)
            }
        }
        return result
    }

    /// Reads pipe-table rows while excluding the separator and header.
    /// - Parameter lines: Lines from a single section.
    /// - Returns: Data rows in source order.
    internal static func table(_ lines: [String]) -> [[String]] {
        var result: [[String]] = []
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard trimmed.hasPrefix(ControlConstants.pipe) else { continue }
            if match(trimmed, ControlConstants.separatorPattern) != nil {
                if !result.isEmpty { result.removeLast() }
                continue
            }
            result.append(tableCells(trimmed))
        }
        return result
    }

    /// Splits a leading-pipe row, preserving escaped pipes and an optional final pipe.
    /// - Parameter line: A trimmed table row beginning with a pipe.
    /// - Returns: Trimmed cells without Markdown delimiter escapes.
    private static func tableCells(_ line: String) -> [String] {
        var cells: [String] = []
        var cell = ControlConstants.empty
        var escaped = false
        var delimiter = false
        for character in line.dropFirst() {
            delimiter = false
            if escaped {
                if String(character) != ControlConstants.pipe && String(character) != ControlConstants.backslash {
                    cell += ControlConstants.backslash
                }
                cell.append(character)
                escaped = false
            } else if String(character) == ControlConstants.backslash {
                escaped = true
            } else if String(character) == ControlConstants.pipe {
                cells.append(cell.trimmingCharacters(in: .whitespaces))
                cell = ControlConstants.empty
                delimiter = true
            } else { cell.append(character) }
        }
        if escaped { cell += ControlConstants.backslash }
        if !delimiter { cells.append(cell.trimmingCharacters(in: .whitespaces)) }
        return cells
    }

    /// Finds meaningful paragraphs without table cells or markup-only lines.
    /// - Parameter sections: Selected source sections.
    /// - Returns: Readable prose blocks in source order.
    internal static func paragraphs(_ sections: [ReadmeSection]) -> [String] {
        sections.flatMap { section in
            section.lines.joined(separator: ControlConstants.newline)
                .components(separatedBy: ControlConstants.newline + ControlConstants.newline)
                .filter { !$0.trimmingCharacters(in: .whitespaces).hasPrefix(ControlConstants.pipe) }
                .map(plain).filter { !$0.isEmpty && match($0, ControlConstants.separatorPattern) == nil }
        }
    }

    /// Extracts architecture tables and documented model mentions outside historical sections.
    /// - Parameter sections: Parsed README sections.
    /// - Returns: At most twelve concise, source-derived facts.
    internal static func architecture(_ sections: [ReadmeSection]) -> [String] {
        let selected = sections.filter { section in
            ControlConstants.architectureWords.contains { section.title.localizedCaseInsensitiveContains($0) }
        }
        var facts = selected.flatMap { table($0.lines).map { $0.map(plain).joined(separator: ControlConstants.joined) } }
        if facts.isEmpty { facts = Array(paragraphs(selected).prefix(3)) }
        let introduction = sections.prefix(2)
        let modelMentions = paragraphs(Array(introduction)).filter { value in
            ControlConstants.modelWords.contains { value.localizedCaseInsensitiveContains($0) }
        }
        for mention in modelMentions where !facts.contains(mention) { facts.append(mention) }
        return Array(facts.prefix(12))
    }

    /// Converts explicit arrow lines to routes without inferring links from bullet order.
    /// - Parameter sections: Parsed README sections.
    /// - Returns: At most eight independent routes, each retaining every written step.
    internal static func workflows(_ sections: [ReadmeSection]) -> [WorkflowRoute] {
        let selected = sections.filter { section in
            ControlConstants.flowWords.contains { section.title.localizedCaseInsensitiveContains($0) }
        }
        return Array(selected.flatMap { section in
            section.lines.compactMap { line -> WorkflowRoute? in
                let text = plain(line).replacingOccurrences(of: ControlConstants.asciiArrow, with: ControlConstants.arrow)
                guard text.contains(ControlConstants.arrow), !text.hasPrefix(ControlConstants.pipe) else { return nil }
                var label = section.title
                var route = text
                if let candidate = match(text, ControlConstants.workflowLabelPattern, group: 1),
                   !candidate.contains(ControlConstants.arrow),
                   let content = match(text, ControlConstants.workflowLabelPattern, group: 2) {
                    label = candidate
                    route = content
                }
                let steps = route.components(separatedBy: ControlConstants.arrow).map(plain).filter { !$0.isEmpty }
                guard steps.count > 1 else { return nil }
                return WorkflowRoute(label: label, steps: steps)
            }
        }.prefix(8))
    }

    /// Extracts structured history tables, falling back to version-labelled release headings.
    /// - Parameter sections: Parsed README sections.
    /// - Returns: Source-ordered history, bounded to the latest thirty entries.
    internal static func history(_ sections: [ReadmeSection]) -> [HistoryEntry] {
        let selected = sections.filter { section in
            ControlConstants.historyWords.contains { section.title.localizedCaseInsensitiveContains($0) }
        }
        let rows = selected.flatMap { table($0.lines) }.filter { $0.count >= 2 }
        if !rows.isEmpty {
            return rows.prefix(30).map { HistoryEntry(title: plain($0[0]), detail: $0.dropFirst().map(plain).joined(separator: ControlConstants.joined)) }
        }
        return sections.filter { match($0.title, ControlConstants.versionPattern) != nil }.prefix(30).map {
            HistoryEntry(title: $0.title, detail: paragraphs([$0]).prefix(2).joined(separator: ControlConstants.space))
        }
    }
}
