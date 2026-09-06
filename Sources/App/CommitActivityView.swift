import SwiftUI

/// Responsive dimensions preserve the supplied desktop and compact table proportions.
private struct CommitActivityMetrics {
    internal let yearWidth: CGFloat
    internal let gap: CGFloat
    internal let monthFont: CGFloat
    internal let yearFont: CGFloat
    internal let countFont: CGFloat
    internal let radius: CGFloat
    internal let footerFont: CGFloat

    internal static let regular = CommitActivityMetrics(
        yearWidth: 53, gap: 6, monthFont: 12, yearFont: 14, countFont: 13, radius: 8, footerFont: 14)
    internal static let compact = CommitActivityMetrics(
        yearWidth: 30, gap: 3, monthFont: 9, yearFont: 11, countFont: 10, radius: 5, footerFont: 12)
}

/// Calculates one fixed year column and twelve equal monthly columns from the live available width.
private struct CommitActivityGridLayout: Layout {
    internal let metrics: CommitActivityMetrics

    /// Reports the exact table height after deriving monthly width and the 1.15:1 cell ratio.
    /// - Parameters: proposal: Width offered by the parent. subviews: Header and year-row cells. cache: Unused layout cache.
    /// - Returns: Full responsive grid size without horizontal overflow or zero-height rows.
    internal func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? minimumWidth
        let values = dimensions(width: width, subviewCount: subviews.count)
        return CGSize(width: width, height: values.height)
    }

    /// Places header labels and activity cells on their calculated row and column coordinates.
    /// - Parameters: bounds: Final layout bounds. proposal: Parent proposal. subviews: Header and year-row cells. cache: Unused layout cache.
    /// - Returns: Nothing; every subview receives an explicit nonzero proposal.
    internal func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize,
                                subviews: Subviews, cache: inout ()) {
        let values = dimensions(width: bounds.width, subviewCount: subviews.count)
        let columns = ControlConstants.monthCount + 1
        for (index, subview) in subviews.enumerated() {
            let row = index / columns
            let column = index % columns
            let width = column == 0 ? metrics.yearWidth : values.cellWidth
            let height = row == 0 ? values.headerHeight : values.cellHeight
            let x = column == 0 ? bounds.minX
                : bounds.minX + metrics.yearWidth + metrics.gap
                    + CGFloat(column - 1) * (values.cellWidth + metrics.gap)
            let y = row == 0 ? bounds.minY
                : bounds.minY + values.headerHeight + metrics.gap
                    + CGFloat(row - 1) * (values.cellHeight + metrics.gap)
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(width: width, height: height))
        }
    }

    private var minimumWidth: CGFloat {
        metrics.yearWidth + CGFloat(ControlConstants.monthCount) * (24 + metrics.gap)
    }

    /// Derives consistent row heights and month widths for the supplied container.
    /// - Parameters: width: Live grid width. subviewCount: Header plus year-row child count.
    /// - Returns: Header height, monthly dimensions, and complete grid height.
    private func dimensions(width: CGFloat, subviewCount: Int) ->
        (headerHeight: CGFloat, cellWidth: CGFloat, cellHeight: CGFloat, height: CGFloat) {
        let columns = ControlConstants.monthCount + 1
        let rows = max(0, subviewCount / columns - 1)
        let gaps = CGFloat(ControlConstants.monthCount) * metrics.gap
        let cellWidth = max(1, (width - metrics.yearWidth - gaps) / CGFloat(ControlConstants.monthCount))
        let cellHeight = cellWidth / 1.15
        let headerHeight = max(16, metrics.monthFont * 1.5)
        let rowGaps = rows > 0 ? CGFloat(rows) * metrics.gap : 0
        let height = headerHeight + rowGaps + CGFloat(rows) * cellHeight
        return (headerHeight, cellWidth, cellHeight, height)
    }
}

/// A native glass heatmap for complete repository commit timestamps.
internal struct CommitActivityView: View {
    internal let activity: CommitActivity
    internal let projects: [ProjectRecord]
    internal let now: Date
    private let calendar = Calendar.autoupdatingCurrent
    @State private var hoveredCell: CommitActivityCell?

    /// Stable hover identity prevents one month's detail card from appearing over another cell.
    private struct CommitActivityCell: Equatable {
        internal let year: Int
        internal let month: Int
    }

    internal var body: some View {
        GlassCard {
            if activity.available {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    ViewThatFits(in: .horizontal) {
                        activityGrid(metrics: .regular)
                            .frame(minWidth: ControlConstants.activityCompactBreakpoint)
                        activityGrid(metrics: .compact)
                    }
                    Divider().overlay(ControlTheme.line)
                    footer
                }
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text(ControlConstants.activityByMonth)
                        .font(.system(size: 22, weight: .semibold))
                    Text(ControlConstants.commitActivityUnavailable)
                        .font(.system(size: 14)).foregroundStyle(ControlTheme.muted)
                }
            }
        }
    }

    private var header: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .firstTextBaseline, spacing: 18) {
                title
                Spacer(minLength: 0)
                legend
            }
            VStack(alignment: .leading, spacing: 12) {
                title
                legend
            }
        }
    }

    private var title: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(ControlConstants.activityByMonth)
                .font(.system(size: 22, weight: .semibold))
            Text(ControlConstants.commitActivityExplanation)
                .font(.system(size: 13)).foregroundStyle(ControlTheme.muted)
        }
    }

    private var legend: some View {
        HStack(spacing: 7) {
            Text(ControlConstants.less)
            HStack(spacing: 4) {
                ForEach(ControlTheme.activityLevels.indices, id: \.self) { level in
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(ControlTheme.activityLevels[level])
                        .frame(width: 16, height: 16)
                        .overlay {
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .stroke(Color.white.opacity(0.28), lineWidth: 1)
                        }
                }
            }
            Text(ControlConstants.more)
        }.font(.system(size: 13, weight: .medium)).foregroundStyle(ControlTheme.muted)
            .accessibilityElement(children: .ignore).accessibilityLabel(ControlConstants.activityLegend)
    }

    /// Builds thirteen responsive grid columns for one year label and twelve months.
    /// - Parameter metrics: Desktop or compact spacing and typography.
    /// - Returns: A grid with newest years first and twelve fixed calendar-month cells per year.
    private func activityGrid(metrics: CommitActivityMetrics) -> some View {
        CommitActivityGridLayout(metrics: metrics) {
            Color.clear
                .accessibilityHidden(true)
            ForEach(Array(ControlConstants.commitActivityMonthLabels.enumerated()), id: \.offset) { _, label in
                Text(label).font(.system(size: metrics.monthFont, weight: .semibold))
                    .foregroundStyle(ControlTheme.muted)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            ForEach(activity.years) { year in
                Text(String(year.year)).font(.system(size: metrics.yearFont, weight: .bold))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                ForEach(0..<ControlConstants.monthCount, id: \.self) { index in
                    monthCell(year: year.year, monthIndex: index,
                        count: year.months.indices.contains(index) ? year.months[index] : 0,
                        distribution: year.projectCounts.indices.contains(index) ? year.projectCounts[index] : [:],
                        metrics: metrics)
                }
            }
        }
    }

    /// Renders one month using fixed absolute intensity thresholds and future-month concealment.
    /// - Parameters: year: Calendar year. monthIndex: Zero-based month. count: Loaded commits. distribution: Project participation counts. metrics: Active layout values.
    /// - Returns: One accessible monthly activity cell.
    private func monthCell(year: Int, monthIndex: Int, count: Int,
                           distribution: [String: Int], metrics: CommitActivityMetrics) -> some View {
        let month = monthIndex + 1
        let future = CommitActivityCalculator.isFuture(year: year, month: month, relativeTo: now, calendar: calendar)
        let intensity = CommitActivityCalculator.intensity(for: count)
        let showsCount = count > 0 && !future
        let identity = CommitActivityCell(year: year, month: month)
        return Button { hoveredCell = identity } label: {
            ZStack {
                RoundedRectangle(cornerRadius: metrics.radius, style: .continuous)
                    .fill(future ? ControlTheme.activityFuture : ControlTheme.activityLevels[intensity])
                Text(showsCount ? String(count) : ControlConstants.empty)
                    .font(.system(size: metrics.countFont, weight: .bold))
                    .foregroundStyle(intensity >= 3 ? Color.white : ControlTheme.ink)
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
        }.buttonStyle(.plain).disabled(!showsCount)
            .overlay {
                RoundedRectangle(cornerRadius: metrics.radius, style: .continuous)
                    .stroke(Color.white.opacity(future ? 0.10 : 0.26), lineWidth: 1)
            }
            .accessibilityLabel(accessibilityLabel(year: year, monthIndex: monthIndex, count: count, future: future))
            .onHover { hovering in
                guard count > 0, !future else { return }
                if hovering { hoveredCell = identity }
                else if hoveredCell == identity { hoveredCell = nil }
            }
            .popover(isPresented: hoverBinding(for: identity), arrowEdge: .bottom) {
                distributionCard(year: year, monthIndex: monthIndex, count: count,
                    distribution: distribution)
            }
    }

    /// Binds one cell's native hover card to the shared hovered identity.
    /// - Parameter identity: Calendar identity owned by the cell.
    /// - Returns: A binding that dismisses only the matching hover card.
    private func hoverBinding(for identity: CommitActivityCell) -> Binding<Bool> {
        Binding(get: { hoveredCell == identity }, set: { presented in
            if !presented && hoveredCell == identity { hoveredCell = nil }
        })
    }

    /// Presents monthly project participation without exposing commit content or changed-file names.
    /// - Parameters: year: Calendar year. monthIndex: Zero-based month. count: Unique monthly commit total. distribution: Per-project participation totals.
    /// - Returns: A compact native card with project icons, names, and counts.
    private func distributionCard(year: Int, monthIndex: Int, count: Int,
                                  distribution: [String: Int]) -> some View {
        let identities = distribution.keys.sorted { left, right in
            let leftCount = distribution[left] ?? 0
            let rightCount = distribution[right] ?? 0
            if leftCount != rightCount { return leftCount > rightCount }
            return projectName(for: left) < projectName(for: right)
        }
        return VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(String(format: ControlConstants.commitDistributionTitleFormat,
                    ControlConstants.commitActivityMonthNames[monthIndex], year))
                    .font(.system(size: 15, weight: .semibold))
                Text(commitCountLabel(count))
                    .font(.caption).foregroundStyle(ControlTheme.muted)
            }
            Divider().overlay(ControlTheme.line)
            ForEach(identities, id: \.self) { identity in
                HStack(spacing: 10) {
                    if let project = project(for: identity) {
                        ProjectIcon(project: project, size: 26)
                    } else {
                        Image(systemName: ControlConstants.repositoryIcon)
                            .font(.system(size: 15, weight: .medium)).foregroundStyle(ControlTheme.mint)
                            .frame(width: 26, height: 26).accessibilityHidden(true)
                    }
                    Text(projectName(for: identity)).font(.system(size: 13, weight: .medium))
                    Spacer(minLength: 18)
                    Text(String(distribution[identity] ?? 0)).font(.system(size: 13, weight: .bold).monospacedDigit())
                }
            }
            Text(ControlConstants.multiProjectCommitNote)
                .font(.system(size: 11)).foregroundStyle(ControlTheme.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16).frame(minWidth: 280)
    }

    /// Resolves a Git path-mapping identity to its current README-registered project.
    /// - Parameter identity: Canonical project identifier recorded in the monthly distribution.
    /// - Returns: Matching project metadata, or nil for repository-level commits.
    private func project(for identity: String) -> ProjectRecord? {
        projects.first { $0.id == identity }
    }

    /// Supplies the README name for a project or the explicit repository-level fallback.
    /// - Parameter identity: Canonical project or repository-level identifier.
    /// - Returns: Human-readable distribution row label.
    private func projectName(for identity: String) -> String {
        project(for: identity)?.name ?? ControlConstants.repositoryLevel
    }

    /// Formats one commit count with the correct singular or plural label.
    /// - Parameter count: Displayed monthly commit count.
    /// - Returns: Readable count shared by the popover and accessibility description.
    private func commitCountLabel(_ count: Int) -> String {
        String(format: count == 1 ? ControlConstants.singleCommitCountFormat : ControlConstants.commitCountFormat, count)
    }

    /// Describes hidden, empty, and populated cells without relying on colour.
    /// - Parameters: year: Calendar year. monthIndex: Zero-based month. count: Loaded commits. future: Whether the value is concealed.
    /// - Returns: Full month, year, and state for assistive technologies.
    private func accessibilityLabel(year: Int, monthIndex: Int, count: Int, future: Bool) -> String {
        let month = ControlConstants.commitActivityMonthNames[monthIndex]
        return future
            ? String(format: ControlConstants.futureMonthAccessibilityFormat, month, year)
            : String(format: ControlConstants.commitMonthAccessibilityFormat, month, year, commitCountLabel(count))
    }

    private var footer: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 20) {
                futureExplanation(font: CommitActivityMetrics.regular.footerFont)
                Spacer(minLength: 0)
                summary(font: CommitActivityMetrics.regular.footerFont)
            }
            VStack(alignment: .leading, spacing: 8) {
                futureExplanation(font: CommitActivityMetrics.compact.footerFont)
                summary(font: CommitActivityMetrics.compact.footerFont)
            }
        }
    }

    /// Styles the future-month explanation for the active footer layout.
    /// - Parameter font: Responsive footer type size.
    /// - Returns: Muted explanatory text.
    private func futureExplanation(font: CGFloat) -> some View {
        Text(ControlConstants.futureMonths).font(.system(size: font)).foregroundStyle(ControlTheme.muted)
    }

    /// Keeps the total visually prominent while distinguishing valid-year count from elapsed span.
    /// - Parameter font: Responsive footer type size.
    /// - Returns: Total commit and distinct-year summary.
    private func summary(font: CGFloat) -> some View {
        HStack(spacing: 4) {
            Text(String(activity.totalCount)).fontWeight(.bold).foregroundStyle(ControlTheme.mint)
            Text(String(format: ControlConstants.commitActivitySummaryRemainderFormat,
                activity.totalCount == 1 ? ControlConstants.commitSingular : ControlConstants.commitPlural,
                activity.yearCount, activity.yearCount == 1 ? ControlConstants.yearSingular : ControlConstants.yearPlural))
                .foregroundStyle(ControlTheme.muted)
        }.font(.system(size: font))
    }
}
