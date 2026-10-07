import SwiftUI

/// Cinematic glass materials with a restrained sage, lime, ink, and cloud palette.
internal enum ControlTheme {
    internal static let background = Color(red: 0.025, green: 0.031, blue: 0.029)
    internal static let rail = Color(red: 0.018, green: 0.024, blue: 0.022)
    /// Text on the smoked glass and on the sky; the artwork keeps its own dark `sceneInk`.
    internal static let ink = Color(red: 0.95, green: 0.96, blue: 0.94)
    internal static let sceneInk = Color(red: 0.08, green: 0.105, blue: 0.095)
    internal static let railInk = Color(red: 0.91, green: 0.925, blue: 0.89)
    internal static let muted = Color(red: 0.78, green: 0.81, blue: 0.79)
    internal static let railMuted = Color(red: 0.61, green: 0.64, blue: 0.60)
    internal static let signal = Color(red: 0.79, green: 0.98, blue: 0.39)
    internal static let line = Color.white.opacity(0.12)
    internal static let amber = Color(red: 0.97, green: 0.74, blue: 0.40)
    internal static let mint = Color(red: 0.49, green: 0.82, blue: 0.64)
    /// The smoked tint laid over the dark material of every content plane.
    internal static let glassTint = Color(red: 0.11, green: 0.14, blue: 0.14).opacity(0.10)
    /// An opaque stand-in for the glass when Reduce Transparency is on.
    internal static let glassSolid = Color(red: 0.27, green: 0.32, blue: 0.31)
    internal static let skyTop = Color(red: 0.55, green: 0.64, blue: 0.64)
    internal static let skyBottom = Color(red: 0.67, green: 0.74, blue: 0.71)
    internal static let cloudLight = Color(red: 0.97, green: 0.93, blue: 0.80)
    internal static let cloudMid = Color(red: 0.88, green: 0.82, blue: 0.66)
    internal static let cloudShade = Color(red: 0.66, green: 0.66, blue: 0.58)
    internal static let cloudPixel: CGFloat = 4
    internal static let sceneTop = Color(red: 0.67, green: 0.76, blue: 0.78)
    internal static let sceneBottom = Color(red: 0.82, green: 0.78, blue: 0.66)
    internal static let sceneWater = Color(red: 0.28, green: 0.48, blue: 0.51)
    internal static let cloud = Color(red: 0.95, green: 0.89, blue: 0.72)
    internal static let activityLevels = [
        Color.white.opacity(0.22),
        Color(red: 0.76, green: 0.84, blue: 0.67),
        Color(red: 0.50, green: 0.66, blue: 0.48),
        Color(red: 0.28, green: 0.50, blue: 0.37),
        Color(red: 0.10, green: 0.29, blue: 0.22)
    ]
    internal static let activityFuture = Color.white.opacity(0.08)
    /// The history strip's five shades, one per entry bin, from a light wash to a deep teal.
    internal static let historyLevels = [
        Color(red: 0.72, green: 0.83, blue: 0.86),
        Color(red: 0.53, green: 0.72, blue: 0.78),
        Color(red: 0.36, green: 0.60, blue: 0.69),
        Color(red: 0.22, green: 0.45, blue: 0.56),
        Color(red: 0.12, green: 0.30, blue: 0.40)
    ]
    internal static let motion = Animation.timingCurve(0.22, 1, 0.36, 1, duration: 0.62)
    /// Each project row disclosed into or out of its category starts this long after the row above it.
    internal static let disclosureStagger = 0.045
    /// The rail's width change; its labels fade for `railLabelFade` before it narrows, and return
    /// `railLabelDelay` after it starts to widen.
    internal static let navigationMotion = Animation.timingCurve(0.4, 0, 0.2, 1, duration: 0.32)
    internal static let railLabelFade = 0.12
    internal static let railLabelDelay = 0.22
    /// A history card grows for `historyGrowDuration`; `historyRevealDelay` after it starts, its panel
    /// fades in over `historyPanelFade` and its lines over `historyLineFade`, the first `historyLineDelay`
    /// after the panel and each later one `historyLineStagger` after the one above. Closing fades the
    /// panel and its lines together over `historyCloseFade`, then shrinks the card.
    internal static let historyGrowDuration = 0.24
    internal static let historyRevealDelay = 0.2
    internal static let historyPanelFade = 0.24
    internal static let historyLineFade = 0.3
    internal static let historyLineDelay = 0.08
    internal static let historyLineStagger = 0.1
    /// Lines beyond this many open together, so a long entry does not keep a reader waiting.
    internal static let historyStaggeredLines = 8
    internal static let historyCloseFade = 0.12
    internal static let historyShrinkDuration = 0.2
    internal static let cardRadius: CGFloat = 18
    internal static let detailFrameInset: CGFloat = 3
    internal static let detailCornerRadius: CGFloat = 18
    internal static let detailFrameWidth: CGFloat = 1
    internal static let collapsedRailWidth: CGFloat = 72
    internal static let expandedRailWidth: CGFloat = 236
    internal static let railLeadingInset: CGFloat = 16
    internal static let railIconSize: CGFloat = 40
    /// The space a workflow connector leaves between itself and each node it joins.
    internal static let diagramConnectorGap: CGFloat = 5
    /// Centered nodes of different widths can land a pixel apart once positions are rounded; closer than
    /// this, two nodes count as lined up and share one straight connector.
    internal static let diagramAlignmentTolerance: CGFloat = 2
    /// The centered column every detail screen reads in; it keeps its width while the rail moves.
    internal static let readingColumnWidth: CGFloat = 870
    /// The space between a screen's tab strip and the content below it, the same on every screen.
    internal static let tabContentGap: CGFloat = 12
    internal static let minimumWindowWidth: CGFloat = 1120
    internal static let minimumWindowHeight: CGFloat = 620
}

/// The smoked-glass plane behind content: a dark material that samples the sky, a tint and a faint rim.
private struct GlassBackground: ViewModifier {
    internal let radius: CGFloat
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    /// Places the plane behind the content.
    /// - Parameter content: The content drawn on the glass.
    /// - Returns: The content over the glass, or over an opaque stand-in when Reduce Transparency is on.
    internal func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: radius, style: .continuous)
        return content
            .background {
                if reduceTransparency { shape.fill(ControlTheme.glassSolid) }
                else {
                    shape.fill(.ultraThinMaterial).environment(\.colorScheme, .dark)
                        .overlay { shape.fill(ControlTheme.glassTint) }
                }
            }
            .overlay { shape.strokeBorder(Color.white.opacity(0.07), lineWidth: 1).allowsHitTesting(false) }
    }
}

extension View {
    /// Sets the view on the shared smoked-glass plane.
    /// - Parameter radius: Corner radius of the plane.
    /// - Returns: The view over the glass.
    internal func glassPlane(radius: CGFloat = ControlTheme.cardRadius) -> some View {
        modifier(GlassBackground(radius: radius))
    }
}

/// The full-width smoked-glass surface under prose groups, empty states, work notes, the project card and
/// the commit heatmap.
internal struct ContentSurface<Content: View>: View {
    private let contentPadding: CGFloat
    private let content: Content

    /// Captures content without adding an interaction or scroll container.
    /// - Parameters:
    ///   - contentPadding: Inset between the surface edge and its content.
    ///   - content: Text, controls, or a grouped set of rows.
    /// - Returns: A surface retaining the supplied content and inset.
    internal init(contentPadding: CGFloat = 20, @ViewBuilder content: () -> Content) {
        self.contentPadding = contentPadding
        self.content = content()
    }

    internal var body: some View {
        content.padding(contentPadding).frame(maxWidth: .infinity, alignment: .leading).glassPlane()
    }
}

/// One row of a screen's tabs; the selected tab carries the signal underline, and a strip wider than
/// its space scrolls sideways without an indicator.
internal struct TabStrip<Tab: Identifiable & Equatable>: View {
    internal let tabs: [Tab]
    internal let label: KeyPath<Tab, String>
    @Binding internal var selection: Tab

    internal var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 20) {
                ForEach(tabs) { tab in
                    Button { selection = tab } label: {
                        Text(tab[keyPath: label]).font(.system(size: 13, weight: selection == tab ? .semibold : .regular))
                            .foregroundStyle(selection == tab ? ControlTheme.ink : ControlTheme.muted)
                            .padding(.vertical, 12).contentShape(Rectangle())
                            .overlay(alignment: .bottom) {
                                if selection == tab { Rectangle().fill(ControlTheme.signal).frame(height: 2) }
                            }
                    }.buttonStyle(.plain).accessibilityAddTraits(selection == tab ? .isSelected : [])
                }
            }
        }.scrollIndicators(.hidden).fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 14)
            .glassPlane(radius: 13)
    }
}
