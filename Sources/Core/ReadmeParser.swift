import Foundation

/// A deliberately limited Markdown extractor, not an HTML renderer or code viewer.
internal enum ReadmeParser {
    /// Replaces regular-expression matches with plain text.
    /// - Parameters:
    ///   - value: Input text.
    ///   - pattern: Trusted expression.
    ///   - replacement: Replacement template.
    /// - Returns: The transformed text.
    internal static func replace(_ value: String, _ pattern: String, _ replacement: String) -> String {
        value.replacingOccurrences(of: pattern, with: replacement, options: .regularExpression)
    }

    /// Extracts a capture group from the first expression match.
    /// - Parameters:
    ///   - value: Input text.
    ///   - pattern: Trusted expression.
    ///   - group: Capture index.
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
        let linked = replace(value, ControlConstants.linkPattern, ControlConstants.linkLabelReplacement)
        let expression = try? NSRegularExpression(pattern: ControlConstants.inlineCodePattern)
        var result = ControlConstants.empty
        var cursor = linked.startIndex
        for match in expression?.matches(in: linked, range: NSRange(linked.startIndex..., in: linked)) ?? [] {
            guard let range = Range(match.range, in: linked), let literal = Range(match.range(at: 2), in: linked) else { continue }
            result += plainProse(String(linked[cursor..<range.lowerBound])) + String(linked[literal])
            cursor = range.upperBound
        }
        result += plainProse(String(linked[cursor...]))
        return replace(result, ControlConstants.whitespacePattern, ControlConstants.space)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Reads one explicitly labelled value from a scope cell without interpreting arbitrary HTML.
    /// - Parameters:
    ///   - value: Raw scope cell.
    ///   - label: Trusted metadata label.
    /// - Returns: Plain nonempty value following the label, or nil when it is absent or blank.
    internal static func labelledValue(_ value: String, label: String) -> String? {
        let pattern = ControlConstants.scopeLabelPatternPrefix
            + NSRegularExpression.escapedPattern(for: label)
            + ControlConstants.scopeLabelPatternSuffix
        guard let matched = match(value, pattern, group: 1) else { return nil }
        let result = plain(matched).trimmingCharacters(in: .whitespacesAndNewlines)
        return result.isEmpty ? nil : result
    }

    /// Removes prose styling while leaving inline-code identifiers and paths to the caller.
    /// - Parameter value: A fragment outside Markdown code spans.
    /// - Returns: Unstyled, inert text with boundary whitespace preserved for concatenation.
    private static func plainProse(_ value: String) -> String {
        var result = replace(value, ControlConstants.htmlBreakPattern, ControlConstants.space)
        result = replace(result, ControlConstants.htmlPattern, ControlConstants.empty)
        result = replace(result, ControlConstants.underscoreEmphasisPattern, ControlConstants.linkLabelReplacement)
        return replace(result, ControlConstants.markupPattern, ControlConstants.empty)
    }

    /// Splits headings, excludes source blocks, and retains text-diagram candidates separately.
    /// - Parameter markdown: UTF-8 README contents.
    /// - Returns: Ordered sections preserving their source headings.
    internal static func sections(_ markdown: String) -> [ReadmeSection] {
        var result = [ReadmeSection(title: ControlConstants.empty, level: 0, lines: [])]
        var fence: String?
        var diagram: [String] = []
        var acceptsDiagram = false
        var pendingMapping: ReadmeTopic?
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
            if line.trimmingCharacters(in: .whitespaces).hasPrefix(ControlConstants.mappingPrefix) {
                if pendingMapping != nil { result[0].mappingInvalid = true }
                if let identifier = match(line, ControlConstants.mappingPattern, group: 1),
                   let topic = ControlConstants.sectionMappings[identifier] {
                    pendingMapping = topic
                } else { result[0].mappingInvalid = true }
                continue
            }
            let isHeading = match(line, ControlConstants.headingPattern, group: 1) != nil
            if pendingMapping != nil && !isHeading && !line.trimmingCharacters(in: .whitespaces).isEmpty {
                result[0].mappingInvalid = true
                pendingMapping = nil
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
                result.append(ReadmeSection(title: plain(heading), level: marker.count, lines: [], mapping: pendingMapping))
                pendingMapping = nil
            } else {
                result[result.count - 1].lines.append(line)
            }
        }
        if pendingMapping != nil { result[0].mappingInvalid = true }
        return result
    }

    /// Rejects invalid routing metadata before a README can replace displayed content.
    /// - Parameter markdown: Bounded README text.
    /// - Returns: Parsed sections, or a readable mapping error.
    internal static func validatedSections(_ markdown: String) throws -> [ReadmeSection] {
        let result = sections(markdown)
        guard !result.contains(where: { $0.mappingInvalid }) else { throw ControlFailure(message: ControlConstants.mappingFailure) }
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

    /// Reads a real pipe-table header, including tables with no data rows.
    /// - Parameter lines: Lines directly owned by a README section.
    /// - Returns: Plain header cells, or an empty array for malformed/headerless content.
    internal static func tableHeaders(_ lines: [String]) -> [String] {
        guard let separator = lines.firstIndex(where: {
            $0.contains(ControlConstants.pipe) && match($0.trimmingCharacters(in: .whitespaces), ControlConstants.separatorPattern) != nil
        }), separator > 0 else { return [] }
        let heading = lines[separator - 1].trimmingCharacters(in: .whitespaces)
        guard heading.hasPrefix(ControlConstants.pipe) else { return [] }
        return tableCells(heading).map(plain)
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
        blocks(sections).filter { $0.kind == .paragraph || $0.kind == .bullet }.map(\.text)
    }

    /// Assigns child headings to their closest documented topic, never extracting release-history details.
    /// - Parameters:
    ///   - sections: Source hierarchy.
    ///   - topic: Requested content owner.
    /// - Returns: Source-ordered sections owned by that topic.
    internal static func topicSections(_ sections: [ReadmeSection], topic: ReadmeTopic) -> [ReadmeSection] {
        let explicit = sections.contains { $0.mapping != nil }
        var ancestors: [(level: Int, topic: ReadmeTopic?)] = []
        var selected: [ReadmeSection] = []
        for section in sections {
            while let last = ancestors.last, last.level >= section.level { ancestors.removeLast() }
            let inherited = ancestors.last.flatMap { $0.topic }
            let owner = inherited == .ignore || inherited == .history ? inherited
                : section.mapping ?? (explicit ? nil : sectionTopic(section.title)) ?? inherited
            ancestors.append((section.level, owner))
            let mixedWorkflow = !explicit && topic == .workflows && owner == .architecture
                && ControlConstants.flowWords.contains { section.title.localizedCaseInsensitiveContains($0) }
            if owner == topic || mixedWorkflow { selected.append(section) }
        }
        return selected
    }

    /// Classifies only recognized README headings; unknown headings inherit their parent.
    /// - Parameter title: Plain source heading.
    /// - Returns: Its content topic, or nil for an unclassified heading.
    private static func sectionTopic(_ title: String) -> ReadmeTopic? {
        if title.lowercased() == ControlConstants.projectsHeading { return .projects }
        if title.localizedCaseInsensitiveContains(ControlConstants.currentReleaseHeading) { return .release }
        if ControlConstants.historyWords.contains(where: { title.localizedCaseInsensitiveContains($0) })
            || title.localizedCaseInsensitiveContains(ControlConstants.releaseNotesHeading)
            || match(title, ControlConstants.versionHeadingPattern) != nil { return .history }
        if ControlConstants.overviewWords.contains(title.lowercased()) { return .overview }
        if ControlConstants.architectureWords.contains(where: { title.localizedCaseInsensitiveContains($0) }) { return .architecture }
        if ControlConstants.flowWords.contains(where: { title.localizedCaseInsensitiveContains($0) }) { return .workflows }
        if ControlConstants.modelHeadingWords.contains(where: { title.localizedCaseInsensitiveContains($0) }) { return .models }
        return nil
    }

    /// Reads an explicit Overview section or the opening description before second-level headings.
    /// - Parameters:
    ///   - sections: Parsed source.
    ///   - fallback: Register summary used only when prose is unavailable.
    /// - Returns: Paragraphs, bullets, and subsection labels in their documented order.
    internal static func overview(_ sections: [ReadmeSection], fallback: String) -> [ReadmeBlock] {
        let explicit = topicSections(sections, topic: .overview)
        let mapped = sections.contains { $0.mapping != nil }
        let selected = explicit.isEmpty && !mapped ? Array(sections.prefix { $0.level < 2 }) : explicit
        let content = blocks(selected, includeHeadings: !explicit.isEmpty)
        return content.isEmpty ? [ReadmeBlock(kind: .paragraph, text: mapped ? ControlConstants.contentUnavailable : fallback)] : content
    }

    /// Tokenizes prose and consecutive table rows once, retaining source order and table headers.
    /// - Parameters:
    ///   - sections: Selected source sections.
    ///   - includeHeadings: Whether to label subsequent sections.
    /// - Returns: Native presentation blocks, with no table row duplicated as prose.
    private static func blocks(_ sections: [ReadmeSection], includeHeadings: Bool = false) -> [ReadmeBlock] {
        var blocks: [ReadmeBlock] = []
        for (index, section) in sections.enumerated() {
            if includeHeadings && index > 0 {
                blocks.append(ReadmeBlock(kind: .heading, text: section.title))
            }
            var paragraph: [String] = []
            var tableLines: [String] = []
            var kind = ReadmeBlock.Kind.paragraph
            for line in section.lines {
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                if trimmed.hasPrefix(ControlConstants.pipe) {
                    appendBlock(&paragraph, kind: kind, to: &blocks)
                    kind = .paragraph
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
        return blocks
    }

    /// Flushes a prose buffer without leaking raw markup into the content view.
    /// - Parameters:
    ///   - lines: Pending source lines, cleared afterward.
    ///   - kind: Paragraph or continued bullet.
    ///   - blocks: Destination blocks.
    /// - Returns: Nothing; appends nonempty readable prose.
    private static func appendBlock(_ lines: inout [String], kind: ReadmeBlock.Kind, to blocks: inout [ReadmeBlock]) {
        let text = plain(lines.joined(separator: ControlConstants.space))
        if !text.isEmpty {
            let standaloneTitle = kind == .paragraph && lines.count == 1
                && match(lines[0].trimmingCharacters(in: .whitespaces), ControlConstants.boldHeadingPattern) != nil
            blocks.append(ReadmeBlock(kind: standaloneTitle ? .heading : kind, text: text))
        }
        lines.removeAll()
    }

    /// Keeps table headers and cells at their source position, excluding delimiter rows.
    /// - Parameters:
    ///   - lines: Pending table lines, cleared afterward.
    ///   - blocks: Destination presentation blocks.
    /// - Returns: Nothing; appends one structured table when it contains data rows.
    private static func appendTable(_ lines: inout [String], to blocks: inout [ReadmeBlock]) {
        let rows = table(lines).map { $0.map(plain) }
        if !rows.isEmpty {
            blocks.append(ReadmeBlock(kind: .table, text: ControlConstants.empty,
                table: ReadmeTable(headers: tableHeaders(lines), rows: rows)))
        }
        lines.removeAll()
    }

    /// Preserves complete architecture tables, including model and retrieval responsibilities.
    /// - Parameter sections: Parsed README sections.
    /// - Returns: Source-derived architecture blocks; dedicated Models and history sections remain separate.
    internal static func architecture(_ sections: [ReadmeSection]) -> [ReadmeBlock] {
        blocks(topicSections(sections, topic: .architecture), includeHeadings: true)
    }

    /// Separates documented model facts from general architecture and introductory prose.
    /// - Parameter sections: Parsed README source.
    /// - Returns: Source-derived prose and tables, without guessing undocumented models.
    internal static func models(_ sections: [ReadmeSection]) -> [ReadmeBlock] {
        blocks(topicSections(sections, topic: .models))
            + modelBlocks(blocks(topicSections(sections, topic: .architecture)))
            + (sections.contains { $0.mapping != nil } ? [] : modelBlocks(blocks(Array(sections.prefix { $0.level < 2 }))))
    }

    /// Reads only the mapped release section, retaining the legacy register fallback for unmarked READMEs.
    /// A release written in bold with a component name, such as `**Observatory v2.7**`, keeps that name,
    /// so a component's version is never shown as the whole project's.
    /// - Parameters:
    ///   - sections: Parsed README.
    ///   - fallback: Root Projects summary.
    /// - Returns: The documented current release, or nil when none is supplied.
    internal static func release(_ sections: [ReadmeSection], fallback: String) -> String? {
        let selected = topicSections(sections, topic: .release)
        let source = selected.flatMap(\.lines).joined(separator: ControlConstants.space)
        if let component = match(source, ControlConstants.componentReleasePattern, group: 1) { return component }
        let text = paragraphs(selected).joined(separator: ControlConstants.space)
        if let value = match(text, ControlConstants.releaseValuePattern) { return value }
        guard !sections.contains(where: { $0.mapping != nil }) else { return nil }
        return match(fallback, ControlConstants.currentReleasePattern, group: 1)
    }

    /// Reads the change-history numbering declaration beside the release or history section.
    /// - Parameter sections: Parsed README.
    /// - Returns: Whether the README declares dated history, which assigns no project release number.
    internal static func usesDatedHistory(_ sections: [ReadmeSection]) -> Bool {
        let owned = topicSections(sections, topic: .release) + topicSections(sections, topic: .history)
        return match(owned.flatMap(\.lines).joined(separator: ControlConstants.space),
            ControlConstants.datedHistoryPattern) != nil
    }

    /// Selects model facts row by row without removing them from the original architecture table.
    /// - Parameter content: Parsed source blocks.
    /// - Returns: Matching blocks and nonempty tables with only their matching rows.
    private static func modelBlocks(_ content: [ReadmeBlock]) -> [ReadmeBlock] {
        content.compactMap { block in
            guard let table = block.table else { return mentionsModel(block.text) ? block : nil }
            let rows = table.rows.filter { $0.contains(where: mentionsModel) }
            guard !rows.isEmpty else { return nil }
            var result = block
            result.table = ReadmeTable(headers: table.headers, rows: rows)
            return result
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
        }.prefix(ControlConstants.maxWorkflowRoutes))
    }

    /// Extracts structured history tables, falling back to version-labelled release headings.
    /// - Parameter sections: Parsed README sections.
    /// - Returns: Source-ordered history, bounded to the latest thirty entries.
    internal static func history(_ sections: [ReadmeSection]) -> [HistoryEntry] {
        let selected = topicSections(sections, topic: .history)
        let rows = selected.flatMap { table($0.lines) }.filter { $0.count >= 2 }
        if !rows.isEmpty {
            return rows.prefix(ControlConstants.maxHistoryEntries).map { source in
                let row = source.map(plain)
                let dateIndex = row.indices.dropFirst().first { match(row[$0], ControlConstants.historyDatePattern) != nil }
                let detail = row.indices.dropFirst().filter { $0 != dateIndex && !row[$0].isEmpty }.map { row[$0] }
                    .joined(separator: ControlConstants.joined)
                return HistoryEntry(title: row[0], detail: detail, date: dateIndex.map { row[$0] })
            }
        }
        return selected.filter { match($0.title, ControlConstants.versionHeadingPattern) != nil }
            .prefix(ControlConstants.maxHistoryEntries).map {
            HistoryEntry(title: $0.title, detail: paragraphs([$0]).prefix(2).joined(separator: ControlConstants.space))
        }
    }
}
