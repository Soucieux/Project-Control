import SwiftUI

/// Shared native rendering for repository/project prose and structured README tables.
internal struct ReadmeContent: View {
    internal let blocks: [ReadmeBlock]
    internal let empty: String
    internal var body: some View {
        LazyVStack(alignment: .leading, spacing: 16) {
            if blocks.isEmpty {
                ContentSurface { Text(empty).font(.callout).foregroundStyle(ControlTheme.muted) }
            }
            ForEach(Array(ReadmeBlock.contentGroups(blocks).enumerated()), id: \.offset) { _, group in
                if group.first?.kind == .paragraph || group.first?.kind == .bullet {
                    ContentSurface {
                        VStack(alignment: .leading, spacing: 16) {
                            ForEach(group) { block in blockContent(block) }
                        }
                    }
                } else {
                    ForEach(group) { block in blockContent(block) }
                }
            }
        }.textSelection(.enabled).frame(maxWidth: .infinity, alignment: .leading)
    }

    /// Renders one source block while its enclosing group owns prose backgrounds.
    /// - Parameter block: Heading, prose, bullet, or table from the README parser.
    /// - Returns: Selectable content with the existing typography and table layout.
    @ViewBuilder private func blockContent(_ block: ReadmeBlock) -> some View {
        switch block.kind {
        case .heading:
            Text(block.text).font(.headline).padding(.top, 8).accessibilityAddTraits(.isHeader)
        case .paragraph:
            Text(block.text).font(.system(size: 14)).lineSpacing(5).foregroundStyle(ControlTheme.muted)
        case .bullet:
            HStack(alignment: .top, spacing: 12) {
                Circle().fill(ControlTheme.signal).frame(width: 4, height: 4).padding(.top, 8).accessibilityHidden(true)
                Text(block.text).font(.system(size: 14)).lineSpacing(5).foregroundStyle(ControlTheme.muted)
            }
        case .table:
            if let table = block.table { ReadmeTableView(table: table) }
        }
    }
}

/// Content-height native table cells; wider tables scroll without clipping their columns.
private struct ReadmeTableView: View {
    internal let table: ReadmeTable
    private var columns: Int { max(table.headers.count, table.rows.map(\.count).max() ?? 0) }

    internal var body: some View {
        Group {
            if columns > 2 {
                ScrollView(.horizontal) { grid(width: 240) }.fixedSize(horizontal: false, vertical: true)
            } else { grid(width: nil) }
        }
        .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
        .glassPlane(radius: 13)
    }

    /// Aligns source headers and data in one grid, preserving empty cells and source row order.
    /// - Parameter width: Fixed column width for horizontal scrolling, or nil for a fitted two-column table.
    /// - Returns: Native table rows with readable wrapping and accessible header/value pairs.
    private func grid(width: CGFloat?) -> some View {
        Grid(alignment: .topLeading, horizontalSpacing: 0, verticalSpacing: 0) {
            if !table.headers.isEmpty {
                GridRow {
                    ForEach(0..<columns, id: \.self) { column in
                        cell(column < table.headers.count ? table.headers[column] : ControlConstants.empty, width: width)
                            .fontWeight(.semibold).foregroundStyle(ControlTheme.ink)
                            .accessibilityAddTraits(.isHeader)
                    }
                }.background(ControlTheme.signal.opacity(0.16))
                Rectangle().fill(ControlTheme.line).frame(height: 1).gridCellUnsizedAxes(.horizontal)
            }
            ForEach(Array(table.rows.enumerated()), id: \.offset) { _, row in
                GridRow {
                    ForEach(0..<columns, id: \.self) { column in
                        let value = column < row.count ? row[column] : ControlConstants.empty
                        cell(value, width: width).foregroundStyle(ControlTheme.muted)
                            .accessibilityLabel((column < table.headers.count ? table.headers[column] + ControlConstants.colon + ControlConstants.space : ControlConstants.empty) + value)
                    }
                }
                Rectangle().fill(ControlTheme.line).frame(height: 1).gridCellUnsizedAxes(.horizontal)
            }
        }
    }

    /// Gives each cell a shared column constraint while its row owns the full-width divider.
    /// - Parameters:
    ///   - value: Inert source text.
    ///   - width: Optional fixed content width.
    /// - Returns: A wrapping, selectable text cell without Markdown delimiters.
    private func cell(_ value: String, width: CGFloat?) -> some View {
        Text(value).font(.system(size: 13)).lineSpacing(4)
            .frame(width: width, alignment: .leading)
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true).padding(12)
    }
}

/// Readable, expandable summaries rather than raw Markdown or source files, under the history strip when the
/// changelog supplies one.
internal struct HistoryList: View {
    internal let entries: [HistoryEntry]
    internal var strip: HistoryStrip? = nil
    internal var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let strip { HistoryStripView(strip: strip) }
            if entries.isEmpty {
                ContentSurface { Text(ControlConstants.noHistory).foregroundStyle(ControlTheme.muted) }
            }
            ForEach(entries) { entry in HistoryCard(entry: entry) }
        }.padding(.vertical, 10)
    }
}

/// The history at a glance: a summary column, then one shaded cell per period — years before the last twelve
/// months, then each month — with a release month's count in an amber pill and its latest version beneath.
private struct HistoryStripView: View {
    internal let strip: HistoryStrip

    internal var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 18) {
                summary.frame(width: 132, alignment: .leading)
                cells
            }
            Text(ControlConstants.stripLegend).font(.system(size: 11)).foregroundStyle(ControlTheme.muted)
        }
        .padding(14).glassPlane(radius: 14)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(String(format: ControlConstants.stripAccessibilityFormat, strip.span, strip.entries,
            strip.versionRange ?? ControlConstants.stripNoReleases))
    }

    /// The span, the entry total, the version range and the release count.
    private var summary: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(strip.span).font(.system(size: 12)).foregroundStyle(ControlTheme.muted)
            HStack(alignment: .firstTextBaseline, spacing: 5) {
                Text(String(strip.entries)).font(.system(size: 26, weight: .semibold))
                Text(strip.entries == 1 ? ControlConstants.stripEntry : ControlConstants.stripEntries)
                    .font(.system(size: 13)).foregroundStyle(ControlTheme.muted)
            }
            if let range = strip.versionRange {
                Text(range).font(.system(size: 12, design: .monospaced))
                Text(String(strip.releases) + ControlConstants.space
                    + (strip.releases == 1 ? ControlConstants.stripRelease : ControlConstants.stripReleases))
                    .font(.system(size: 12)).foregroundStyle(ControlTheme.muted)
            } else {
                Text(ControlConstants.stripNoReleases).font(.system(size: 12)).foregroundStyle(ControlTheme.muted)
            }
        }
    }

    /// The period cells, a hairline between the years and the months.
    private var cells: some View {
        HStack(alignment: .top, spacing: 3) {
            ForEach(Array(strip.periods.enumerated()), id: \.element.id) { index, period in
                if index > 0 && period.isMonth && !strip.periods[index - 1].isMonth {
                    Rectangle().fill(ControlTheme.line).frame(width: 1, height: 32).padding(.top, 30).padding(.horizontal, 4)
                }
                cell(period, first: index == 0)
            }
        }.frame(maxWidth: .infinity, alignment: .leading)
    }

    /// One period: its context year, its label, the shaded cell with its count, and its release pill and version.
    /// - Parameters:
    ///   - period: The period drawn.
    ///   - first: Whether it is the first cell, which carries the "by year" or "by month" context.
    /// - Returns: The cell column.
    private func cell(_ period: HistoryPeriod, first: Bool) -> some View {
        let context = first ? (period.isMonth ? ControlConstants.stripByMonth : ControlConstants.stripByYear)
            + (period.yearLabel.map { ControlConstants.joined + $0 } ?? ControlConstants.empty) : period.yearLabel
        let level = ControlConstants.stripBins.lastIndex { period.entries >= $0 }
        return VStack(spacing: 3) {
            Text(context ?? ControlConstants.space).font(.system(size: 10)).foregroundStyle(ControlTheme.muted)
                .lineLimit(1).fixedSize()
            Text(period.label).font(.system(size: 11)).foregroundStyle(ControlTheme.muted)
            ZStack {
                if let level {
                    RoundedRectangle(cornerRadius: 5, style: .continuous).fill(ControlTheme.historyLevels[level])
                    Text(String(period.entries)).font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(level >= 3 ? ControlTheme.ink : ControlTheme.sceneInk)
                } else {
                    RoundedRectangle(cornerRadius: 5, style: .continuous).stroke(ControlTheme.line, lineWidth: 1)
                }
            }.frame(minWidth: 26, maxWidth: 60).frame(height: 32)
            if period.releases > 0 {
                Text(String(period.releases)).font(.system(size: 9, weight: .bold)).foregroundStyle(ControlTheme.sceneInk)
                    .frame(maxWidth: .infinity).frame(height: 12)
                    .background(ControlTheme.amber, in: RoundedRectangle(cornerRadius: 4, style: .continuous))
                Text(period.latestVersion ?? ControlConstants.empty).font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(ControlTheme.muted).lineLimit(1).fixedSize()
            }
        }.frame(minWidth: 26, maxWidth: 60)
    }
}

/// One history record as a glass card: its title and date beside a round disclosure button, opening a darker
/// panel inside the same card. The card grows first, then the panel fades in and its lines follow from the
/// top; closing fades the panel and its lines together, then shrinks the card. Reduce Motion opens and
/// closes it at once.
private struct HistoryCard: View {
    internal let entry: HistoryEntry
    /// The state last asked for; `followOpenRequest` moves the card towards it in two steps.
    @State private var open = false
    /// Whether the panel is in the card, which has grown to hold it.
    @State private var expanded = false
    /// Whether the panel and its lines are visible.
    @State private var revealed = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    internal var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button { open.toggle() } label: {
                HStack(spacing: 12) {
                    Text(entry.heading).font(.callout.weight(.medium)).multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Image(systemName: ControlConstants.expandedIcon).font(.system(size: 10, weight: .semibold))
                        .rotationEffect(.degrees(expanded ? 180 : 0))
                        .frame(width: 26, height: 26)
                        .background(Color.white.opacity(0.10), in: Circle())
                        .overlay { Circle().stroke(Color.white.opacity(0.12), lineWidth: 1) }
                        .accessibilityHidden(true)
                }.contentShape(Rectangle())
            }.buttonStyle(.plain)
                .accessibilityValue(open ? ControlConstants.expanded : ControlConstants.collapsed)
            if expanded {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(Array(panelLines.enumerated()), id: \.offset) { index, line in
                        Text(line.text).font(line.isName ? .callout.weight(.semibold) : .callout).lineSpacing(4)
                            .foregroundStyle(line.isName ? ControlTheme.ink : ControlTheme.muted)
                            .padding(.top, line.isName ? 6 : 0)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .opacity(revealed ? 1 : 0).offset(y: revealed ? 0 : 4)
                            .animation(reduceMotion ? nil : revealed
                                ? .easeOut(duration: ControlTheme.historyLineFade)
                                    .delay(ControlTheme.historyLineDelay + Double(min(index, ControlTheme.historyStaggeredLines))
                                        * ControlTheme.historyLineStagger)
                                : .easeIn(duration: ControlTheme.historyCloseFade),
                                value: revealed)
                    }
                }
                .textSelection(.enabled).padding(14)
                .background(Color.black.opacity(revealed ? 0.24 : 0),
                    in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                .animation(reduceMotion ? nil : revealed ? .easeOut(duration: ControlTheme.historyPanelFade)
                    : .easeIn(duration: ControlTheme.historyCloseFade), value: revealed)
                .transition(.identity)
            }
        }
        .padding(14).glassPlane(radius: 14)
        .task(id: open) { await followOpenRequest() }
    }

    /// The panel's lines: the summary, then each subsection's name followed by its lines.
    private var panelLines: [(text: String, isName: Bool)] {
        entry.lines.map { ($0, false) } + entry.sections.flatMap { section in
            [(section.name, true)] + section.lines.map { ($0, false) }
        }
    }

    /// Moves the card to the state last asked for in two steps: opening grows the card before the panel and
    /// its lines appear, and closing fades them before the card shrinks. A newer request cancels the step
    /// still waiting, so quick repeated clicks always end in the state last asked for.
    /// - Returns: Nothing; changes only local presentation state.
    private func followOpenRequest() async {
        let opening = open
        guard expanded != opening || revealed != opening else { return }
        if reduceMotion {
            expanded = opening
            revealed = opening
        } else if opening {
            withAnimation(.easeOut(duration: ControlTheme.historyGrowDuration)) { expanded = true }
            try? await Task.sleep(for: .seconds(ControlTheme.historyRevealDelay))
            guard !Task.isCancelled else { return }
            revealed = true
        } else {
            revealed = false
            try? await Task.sleep(for: .seconds(ControlTheme.historyCloseFade))
            guard !Task.isCancelled else { return }
            withAnimation(.easeInOut(duration: ControlTheme.historyShrinkDuration)) { expanded = false }
        }
    }
}
