import SwiftUI

/// Vector geometry with the selected Lens navy and icy-blue palette.
internal enum ControlTheme {
    internal static let background = Color(red: 0.047, green: 0.078, blue: 0.133)
    internal static let surface = Color(red: 0.075, green: 0.12, blue: 0.19)
    internal static let rail = Color(red: 0.13, green: 0.19, blue: 0.28)
    internal static let ink = Color(red: 0.95, green: 0.96, blue: 1)
    internal static let muted = Color(red: 0.75, green: 0.79, blue: 0.86)
    internal static let signal = Color(red: 0.75, green: 0.84, blue: 1)
    internal static let line = signal.opacity(0.25)
    internal static let amber = Color(red: 0.94, green: 0.84, blue: 0.65)
    internal static let mint = Color(red: 0.76, green: 0.86, blue: 0.83)
    internal static let motion = Animation.easeOut(duration: 0.20)
}

/// A single consistent chamfer, used only on the main project boundary.
internal struct InstrumentFrame: Shape {
    /// Draws cut top-left and bottom-right corners.
    /// - Parameter rect: Available frame bounds.
    /// - Returns: A closed, noninteractive outline.
    internal func path(in rect: CGRect) -> Path {
        let cut: CGFloat = 16
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + cut, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - cut))
        path.addLine(to: CGPoint(x: rect.maxX - cut, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + cut))
        path.closeSubpath()
        return path
    }
}

/// A compact section label with semantic hierarchy, not decorative telemetry.
internal struct InstrumentLabel: View {
    internal let title: String
    internal var body: some View {
        Text(title).font(.system(size: 11, weight: .medium, design: .monospaced))
            .tracking(1.4).foregroundStyle(ControlTheme.muted)
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
            Circle().trim(from: 0, to: fraction).stroke(ControlTheme.signal, style: StrokeStyle(lineWidth: 4, lineCap: .butt))
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
