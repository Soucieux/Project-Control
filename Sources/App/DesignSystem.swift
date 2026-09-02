import SwiftUI

/// Cinematic glass materials with a restrained sage, lime, ink, and cloud palette.
internal enum ControlTheme {
    internal static let background = Color(red: 0.025, green: 0.031, blue: 0.029)
    internal static let surface = Color(red: 0.94, green: 0.955, blue: 0.93)
    internal static let surfaceStrong = Color(red: 0.975, green: 0.982, blue: 0.965)
    internal static let rail = Color(red: 0.018, green: 0.024, blue: 0.022)
    internal static let ink = Color(red: 0.08, green: 0.105, blue: 0.095)
    internal static let railInk = Color(red: 0.91, green: 0.925, blue: 0.89)
    internal static let muted = Color(red: 0.32, green: 0.37, blue: 0.35)
    internal static let railMuted = Color(red: 0.61, green: 0.64, blue: 0.60)
    internal static let signal = Color(red: 0.79, green: 0.98, blue: 0.39)
    internal static let line = Color.black.opacity(0.13)
    internal static let amber = Color(red: 0.67, green: 0.43, blue: 0.14)
    internal static let mint = Color(red: 0.20, green: 0.50, blue: 0.39)
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
    internal static let motion = Animation.timingCurve(0.22, 1, 0.36, 1, duration: 0.62)
    internal static let navigationMotion = Animation.timingCurve(0.22, 1, 0.36, 1, duration: 0.78)
    internal static let cardRadius: CGFloat = 18
    internal static let detailFrameInset: CGFloat = 3
    internal static let detailCornerRadius: CGFloat = 18
    internal static let detailFrameWidth: CGFloat = 1
    internal static let detailBackdropBlur: CGFloat = 10
    internal static let detailHalftoneOpacity = 0.48
    internal static let collapsedRailWidth: CGFloat = 72
    internal static let expandedRailWidth: CGFloat = 250
    internal static let railLeadingInset: CGFloat = 16
    internal static let railIconSize: CGFloat = 40
    internal static let footerMetadataInset: CGFloat = 11
}

/// A compact section label with semantic hierarchy, not decorative telemetry.
internal struct InstrumentLabel: View {
    internal let title: String
    internal var body: some View {
        Text(title).font(.system(size: 11, weight: .medium, design: .monospaced))
            .tracking(1.4).foregroundStyle(ControlTheme.muted)
    }
}

/// A rounded, softly elevated information surface shared by project content.
internal struct GlassCard<Content: View>: View {
    private let content: Content

    /// Stores the card content without introducing a second interaction layer.
    /// - Parameter content: Readable native content placed on the translucent surface.
    internal init(@ViewBuilder content: () -> Content) { self.content = content() }

    internal var body: some View {
        content.padding(22)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(ControlTheme.surfaceStrong.opacity(0.72), in: RoundedRectangle(cornerRadius: ControlTheme.cardRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: ControlTheme.cardRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.42), lineWidth: 1)
                    .allowsHitTesting(false)
            }
            .shadow(color: Color.black.opacity(0.08), radius: 18, y: 8)
    }
}

/// Progress reports completed user notes; zero notes is intentionally not a percentage.
internal struct NoteGauge: View {
    internal let notes: [WorkNote]
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private var completed: Int { notes.filter { $0.status == .done }.count }
    private var fraction: Double { notes.isEmpty ? 0 : Double(completed) / Double(notes.count) }
    internal var body: some View {
        ZStack {
            Circle().stroke(ControlTheme.line, style: StrokeStyle(lineWidth: 3, dash: [2, 5]))
            Circle().trim(from: 0, to: fraction).stroke(ControlTheme.mint, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90)).animation(reduceMotion ? nil : .easeOut(duration: 0.48), value: fraction)
            VStack(spacing: 4) {
                Text(notes.isEmpty ? ControlConstants.noProgress : String(format: ControlConstants.noteCountFormat, completed, notes.count))
                    .font(.system(size: notes.isEmpty ? 15 : 23, weight: .light, design: .rounded))
                if !notes.isEmpty { Text(ControlConstants.completedNotes).font(.system(size: 10)).foregroundStyle(ControlTheme.muted) }
            }
        }.frame(width: 112, height: 112)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(ControlConstants.completedNotes)
            .accessibilityValue(notes.isEmpty ? ControlConstants.noProgress : String(format: ControlConstants.noteCountFormat, completed, notes.count))
    }
}
