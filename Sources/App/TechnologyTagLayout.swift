import SwiftUI

/// Content-sized, noninteractive tags wrap to the sidebar width without truncating their labels.
internal struct TechnologyTagLayout: Layout {
    private let spacing: CGFloat = 4

    /// Measures the same rows used for placement, including wrapped labels and empty content.
    /// - Parameters:
    ///   - proposal: Available size.
    ///   - subviews: Tag views.
    ///   - cache: Unused layout cache.
    /// - Returns: The bounded row width and complete content height.
    internal func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        arrangement(width: proposal.width, subviews: subviews).size
    }

    /// Places each tag at its measured row position inside the supplied bounds.
    /// - Parameters:
    ///   - bounds: Container rectangle.
    ///   - proposal: Available size.
    ///   - subviews: Tag views.
    ///   - cache: Unused cache.
    /// - Returns: Nothing; positions the supplied subviews without changing their content.
    internal func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let layout = arrangement(width: bounds.width, subviews: subviews)
        for (index, subview) in subviews.enumerated() {
            let frame = layout.frames[index]
            subview.place(at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY),
                anchor: .topLeading, proposal: ProposedViewSize(frame.size))
        }
    }

    /// Packs intrinsic tag widths into bounded rows and measures long labels at that width.
    /// - Parameters:
    ///   - width: Optional available width.
    ///   - subviews: Ordered tags to measure.
    /// - Returns: Placement frames and the total content size; no rows when tags are absent.
    private func arrangement(width: CGFloat?, subviews: Subviews) -> (frames: [CGRect], size: CGSize) {
        let limit = max(0, width ?? .infinity)
        var frames: [CGRect] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var usedWidth: CGFloat = 0
        for subview in subviews {
            let ideal = subview.sizeThatFits(.unspecified)
            let size = subview.sizeThatFits(ProposedViewSize(width: min(ideal.width, limit), height: nil))
            if x > 0 && x + size.width > limit {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            frames.append(CGRect(origin: CGPoint(x: x, y: y), size: size))
            usedWidth = max(usedWidth, x + size.width)
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }
        return (frames, CGSize(width: usedWidth, height: frames.isEmpty ? 0 : y + rowHeight))
    }
}
