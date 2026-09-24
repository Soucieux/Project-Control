import SwiftUI

/// Native, content-sized nodes with connectors anchored to their actual bounds.
internal struct WorkflowDiagram: View {
    internal let route: WorkflowRoute
    private var layers: [Int] { Array(Set(route.nodes.map(\.layer))).sorted() }
    private var accessibleConnections: String {
        route.edges.map { edge in
            route.nodes[edge.source].label + ControlConstants.space + ControlConstants.arrow
                + ControlConstants.space + route.nodes[edge.target].label
        }.joined(separator: ControlConstants.newline)
    }

    internal var body: some View {
        ViewThatFits(in: .horizontal) {
            graph.fixedSize(horizontal: true, vertical: false)
                .frame(maxWidth: .infinity, alignment: .center)
            ScrollView(.horizontal) { graph }.scrollIndicators(.hidden)
        }.fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .center)
            .background(ControlTheme.surface.opacity(0.54), in: RoundedRectangle(cornerRadius: ControlTheme.cardRadius, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: ControlTheme.cardRadius, style: .continuous).stroke(ControlTheme.line, lineWidth: 1).allowsHitTesting(false))
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(route.label).accessibilityValue(accessibleConnections)
    }

    private var graph: some View {
        VStack(spacing: 44) {
            ForEach(layers, id: \.self) { layer in
                HStack(alignment: .center, spacing: 24) {
                    ForEach(route.nodes.filter { $0.layer == layer }) { node in
                        WrappedLabel(maxWidth: 224) {
                            Text(node.label).font(.system(size: 13)).lineSpacing(4)
                                .multilineTextAlignment(.center).foregroundStyle(ControlTheme.ink)
                        }.padding(14)
                            .background(ControlTheme.surfaceStrong.opacity(0.72), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(ControlTheme.mint.opacity(0.5), lineWidth: 1))
                            .anchorPreference(key: WorkflowBounds.self, value: .bounds) { [node.id: $0] }
                    }
                }
            }
        }.padding(20)
            .backgroundPreferenceValue(WorkflowBounds.self) { anchors in
                GeometryReader { proxy in
                    connections(anchors, proxy: proxy)
                        .stroke(ControlTheme.mint.opacity(0.8), style: StrokeStyle(lineWidth: 1.4, lineJoin: .round))
                }.allowsHitTesting(false).accessibilityHidden(true)
            }
    }

    /// Draws directional edges between measured nodes without guessing any additional relationship.
    /// - Parameters:
    ///   - anchors: Current node bounds.
    ///   - proxy: Shared diagram coordinate space.
    /// - Returns: Orthogonal connectors and arrowheads, beneath the node surfaces. Each elbow sits midway
    ///   between the two rows, so a branch or merge shares one line even when its nodes differ in height.
    private func connections(_ anchors: [Int: Anchor<CGRect>], proxy: GeometryProxy) -> Path {
        var rows: [Int: (top: CGFloat, bottom: CGFloat)] = [:]
        for node in route.nodes {
            guard let anchor = anchors[node.id] else { continue }
            let frame = proxy[anchor]
            let row = rows[node.layer]
            rows[node.layer] = (min(row?.top ?? frame.minY, frame.minY), max(row?.bottom ?? frame.maxY, frame.maxY))
        }
        var path = Path()
        for edge in route.edges {
            guard let source = anchors[edge.source], let target = anchors[edge.target],
                  let above = rows[route.nodes[edge.source].layer],
                  let below = rows[route.nodes[edge.target].layer] else { continue }
            let from = proxy[source]
            let to = proxy[target]
            let middle = (above.bottom + below.top) / 2
            path.move(to: CGPoint(x: from.midX, y: from.maxY))
            path.addLine(to: CGPoint(x: from.midX, y: middle))
            path.addLine(to: CGPoint(x: to.midX, y: middle))
            path.addLine(to: CGPoint(x: to.midX, y: to.minY))
            path.move(to: CGPoint(x: to.midX - 4, y: to.minY - 7))
            path.addLine(to: CGPoint(x: to.midX, y: to.minY))
            path.addLine(to: CGPoint(x: to.midX + 4, y: to.minY - 7))
        }
        return path
    }
}

/// Measures one label at the width it draws at, so a pass that proposes no width cannot size wrapped text as one line.
private struct WrappedLabel: Layout {
    fileprivate let maxWidth: CGFloat

    /// Sizes the label at its natural width, capped at the node limit and the offered width.
    /// - Parameters:
    ///   - proposal: Offered size; an unspecified width still wraps at `maxWidth`.
    ///   - subviews: The single label.
    ///   - cache: Unused.
    /// - Returns: The width the label draws at and its full wrapped height.
    fileprivate func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        guard let label = subviews.first else { return .zero }
        let width = min(label.sizeThatFits(.unspecified).width, maxWidth, proposal.width ?? .infinity)
        return label.sizeThatFits(ProposedViewSize(width: width, height: nil))
    }

    /// Places the label across the bounds it was measured for.
    /// - Parameters:
    ///   - bounds: Measured label rectangle.
    ///   - proposal: Offered size.
    ///   - subviews: The single label.
    ///   - cache: Unused.
    /// - Returns: Nothing; positions the label without changing its content.
    fileprivate func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        subviews.first?.place(at: bounds.origin, anchor: .topLeading, proposal: ProposedViewSize(bounds.size))
    }
}

/// Collects measured node anchors without imposing a fixed text height.
private struct WorkflowBounds: PreferenceKey {
    fileprivate static let defaultValue: [Int: Anchor<CGRect>] = [:]

    /// Merges node bounds from each row into the graph coordinate space.
    /// - Parameters:
    ///   - value: Accumulated anchors.
    ///   - nextValue: Next child anchors.
    /// - Returns: Nothing; each source node retains its unique measured bounds.
    fileprivate static func reduce(value: inout [Int: Anchor<CGRect>], nextValue: () -> [Int: Anchor<CGRect>]) {
        value.merge(nextValue(), uniquingKeysWith: { _, new in new })
    }
}
