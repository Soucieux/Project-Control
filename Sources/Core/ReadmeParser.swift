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

    /// Splits headings, excludes source blocks, and retains text-diagram candidates separately.
    /// - Parameter markdown: UTF-8 README contents.
    /// - Returns: Ordered sections preserving their source headings.
    internal static func sections(_ markdown: String) -> [ReadmeSection] {
        var result = [ReadmeSection(title: ControlConstants.empty, level: 0, lines: [])]
        var fence: String?
        var diagram: [String] = []
        var acceptsDiagram = false
        for line in markdown.components(separatedBy: .newlines) {
            if let current = fence {
                if let marker = match(line, ControlConstants.closingFencePattern, group: 1),
                   marker.first == current.first && marker.count >= current.count {
                    if acceptsDiagram { result[result.count - 1].diagrams.append(diagram) }
                    fence = nil
                    diagram = []
                } else if acceptsDiagram { diagram.append(line) }
                continue
            }
            if let marker = match(line, ControlConstants.fencePattern, group: 1) {
                fence = marker
                let language = line.trimmingCharacters(in: .whitespaces).dropFirst(marker.count)
                    .trimmingCharacters(in: .whitespaces).lowercased()
                acceptsDiagram = ControlConstants.diagramLanguages.contains(language)
                continue
            }
            if let heading = match(line, ControlConstants.headingPattern, group: 2),
               let marker = match(line, ControlConstants.headingPattern, group: 1) {
                result.append(ReadmeSection(title: plain(heading), level: marker.count, lines: []))
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

    /// Assigns child headings to their closest documented topic, never extracting release-history details.
    /// - Parameters: sections: Source hierarchy. topic: Requested content owner.
    /// - Returns: Source-ordered sections owned by that topic.
    internal static func topicSections(_ sections: [ReadmeSection], topic: ProjectTab) -> [ReadmeSection] {
        var ancestors: [(level: Int, topic: ProjectTab?)] = []
        var selected: [ReadmeSection] = []
        for section in sections {
            while let last = ancestors.last, last.level >= section.level { ancestors.removeLast() }
            let inherited = ancestors.last.flatMap { $0.topic }
            let owner = inherited == .history ? .history : sectionTopic(section.title) ?? inherited
            ancestors.append((section.level, owner))
            if owner == topic { selected.append(section) }
        }
        return selected
    }

    /// Classifies only recognized README headings; unknown headings inherit their parent.
    /// - Parameter title: Plain source heading.
    /// - Returns: Its content topic, or nil for an unclassified heading.
    private static func sectionTopic(_ title: String) -> ProjectTab? {
        if ControlConstants.historyWords.contains(where: { title.localizedCaseInsensitiveContains($0) })
            || title.localizedCaseInsensitiveContains(ControlConstants.releaseNotesHeading)
            || match(title, ControlConstants.versionHeadingPattern) != nil { return .history }
        if ControlConstants.overviewWords.contains(title.lowercased()) { return .overview }
        if ControlConstants.flowWords.contains(where: { title.localizedCaseInsensitiveContains($0) }) { return .workflows }
        if ControlConstants.modelHeadingWords.contains(where: { title.localizedCaseInsensitiveContains($0) }) { return .models }
        if ControlConstants.architectureWords.contains(where: { title.localizedCaseInsensitiveContains($0) }) { return .architecture }
        return nil
    }

    /// Reads an explicit Overview section or the opening description before second-level headings.
    /// - Parameters: sections: Parsed source. fallback: Register summary used only when prose is unavailable.
    /// - Returns: Paragraphs, bullets, and subsection labels in their documented order.
    internal static func overview(_ sections: [ReadmeSection], fallback: String) -> [ReadmeBlock] {
        let explicit = topicSections(sections, topic: .overview)
        let selected = explicit.isEmpty ? Array(sections.prefix { $0.level < 2 }) : explicit
        var blocks: [ReadmeBlock] = []
        for (index, section) in selected.enumerated() {
            if !explicit.isEmpty && index > 0 {
                blocks.append(ReadmeBlock(kind: .heading, text: section.title))
            }
            var paragraph: [String] = []
            var tableLines: [String] = []
            var kind = ReadmeBlock.Kind.paragraph
            for line in section.lines {
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                if trimmed.hasPrefix(ControlConstants.pipe) {
                    appendBlock(&paragraph, kind: kind, to: &blocks)
                    tableLines.append(line)
                    continue
                }
                appendTable(&tableLines, to: &blocks)
                if trimmed.isEmpty
                    || match(trimmed, ControlConstants.separatorPattern) != nil
                    || match(trimmed, ControlConstants.imageLinePattern) != nil {
                    appendBlock(&paragraph, kind: kind, to: &blocks)
                    kind = .paragraph
                    continue
                }
                if let item = match(line, ControlConstants.listItemPattern, group: 1) {
                    appendBlock(&paragraph, kind: kind, to: &blocks)
                    kind = .bullet
                    paragraph.append(item)
                } else { paragraph.append(line) }
            }
            appendBlock(&paragraph, kind: kind, to: &blocks)
            appendTable(&tableLines, to: &blocks)
        }
        return blocks.isEmpty ? [ReadmeBlock(kind: .paragraph, text: fallback)] : blocks
    }

    /// Flushes a prose buffer without leaking raw markup into the content view.
    /// - Parameters: lines: Pending source lines, cleared afterward. kind: Paragraph or continued bullet. blocks: Destination blocks.
    /// - Returns: Nothing; appends nonempty readable prose.
    private static func appendBlock(_ lines: inout [String], kind: ReadmeBlock.Kind, to blocks: inout [ReadmeBlock]) {
        let text = plain(lines.joined(separator: ControlConstants.space))
        if !text.isEmpty { blocks.append(ReadmeBlock(kind: kind, text: text)) }
        lines.removeAll()
    }

    /// Keeps overview table facts at their source position instead of moving them below the prose.
    /// - Parameters: lines: Pending table lines, cleared afterward. blocks: Destination presentation blocks.
    /// - Returns: Nothing; appends only data rows, without the Markdown header or delimiter.
    private static func appendTable(_ lines: inout [String], to blocks: inout [ReadmeBlock]) {
        blocks += table(lines).map { ReadmeBlock(kind: .bullet, text: $0.map(plain).joined(separator: ControlConstants.joined)) }
        lines.removeAll()
    }

    /// Extracts non-model architecture facts without including workflow or historical sections.
    /// - Parameter sections: Parsed README sections.
    /// - Returns: Source-derived architecture facts, with model information separated out.
    internal static func architecture(_ sections: [ReadmeSection]) -> [String] {
        facts(topicSections(sections, topic: .architecture)).filter { !mentionsModel($0) }
    }

    /// Separates documented model facts from general architecture and introductory prose.
    /// - Parameter sections: Parsed README source.
    /// - Returns: Unique source-derived model descriptions, without guessing undocumented models.
    internal static func models(_ sections: [ReadmeSection]) -> [String] {
        let values = facts(topicSections(sections, topic: .models))
            + facts(topicSections(sections, topic: .architecture)).filter(mentionsModel)
            + paragraphs(Array(sections.prefix { $0.level < 2 })).filter(mentionsModel)
        var seen: Set<String> = []
        return values.filter { seen.insert($0).inserted }
    }

    /// Collects readable table facts and explanatory prose from selected sections.
    /// - Parameter sections: Sections already assigned to a content topic.
    /// - Returns: Display-ready facts without source code or Markdown syntax.
    private static func facts(_ sections: [ReadmeSection]) -> [String] {
        sections.flatMap { section in
            table(section.lines).map { $0.map(plain).joined(separator: ControlConstants.joined) } + paragraphs([section])
        }
    }

    /// Recognizes documented language, embedding, and speech-model mentions.
    /// - Parameter text: A source-derived fact.
    /// - Returns: Whether it belongs in the Models tab.
    private static func mentionsModel(_ text: String) -> Bool {
        ControlConstants.modelWords.contains { text.localizedCaseInsensitiveContains($0) }
    }

    /// Converts explicit arrow lines to routes without inferring links from bullet order.
    /// - Parameter sections: Parsed README sections.
    /// - Returns: At most eight independent routes, each retaining every written step.
    internal static func workflows(_ sections: [ReadmeSection]) -> [WorkflowRoute] {
        let selected = topicSections(sections, topic: .workflows)
        return Array(selected.flatMap { section in
            section.lines.compactMap { WorkflowParser.linear($0, label: section.title) }
                + section.diagrams.flatMap { WorkflowParser.diagrams($0, label: section.title) }
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
        return sections.filter { match($0.title, ControlConstants.versionHeadingPattern) != nil }.prefix(30).map {
            HistoryEntry(title: $0.title, detail: paragraphs([$0]).prefix(2).joined(separator: ControlConstants.space))
        }
    }
}
