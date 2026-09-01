import SwiftUI

/// Shared native rendering for repository/project prose and structured README tables.
internal struct ReadmeContent: View {
    internal let blocks: [ReadmeBlock]
    internal let empty: String

    internal var body: some View {
        LazyVStack(alignment: .leading, spacing: 16) {
            if blocks.isEmpty { Text(empty).font(.callout).foregroundStyle(ControlTheme.muted) }
            ForEach(blocks) { block in
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
        }.textSelection(.enabled).frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Content-height native table cells; wider tables scroll without clipping their columns.
internal struct ReadmeTableView: View {
    internal let table: ReadmeTable
    private var columns: Int { max(table.headers.count, table.rows.map(\.count).max() ?? 0) }

    internal var body: some View {
        Group {
            if columns > 2 {
                ScrollView(.horizontal) { grid(width: 240) }.fixedSize(horizontal: false, vertical: true)
            } else { grid(width: nil) }
        }
        .background(ControlTheme.surfaceStrong.opacity(0.68))
        .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 13, style: .continuous).stroke(ControlTheme.line, lineWidth: 1).allowsHitTesting(false))
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
    /// - Parameters: value: Inert source text. width: Optional fixed content width.
    /// - Returns: A wrapping, selectable text cell without Markdown delimiters.
    private func cell(_ value: String, width: CGFloat?) -> some View {
        Text(value).font(.system(size: 13)).lineSpacing(4)
            .frame(width: width, alignment: .leading)
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true).padding(12)
    }
}
