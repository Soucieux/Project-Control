import AppKit
import SwiftUI

/// Makes the host window transparent so behind-window material can reveal the desktop.
internal struct WindowTransparencyConfigurator: NSViewRepresentable {
    /// Creates a passive view that configures its containing window after attachment.
    /// - Parameter context: SwiftUI representable context.
    /// - Returns: A transparent AppKit bridge view.
    internal func makeNSView(context: Context) -> NSView { TransparentWindowBridge() }

    /// Keeps the bridge inert after the one-time window configuration.
    /// - Parameters: nsView: Existing bridge. context: SwiftUI representable context.
    /// - Returns: Nothing; visible state remains owned by SwiftUI.
    internal func updateNSView(_ nsView: NSView, context: Context) {}
}

/// Configures only the containing Project Control window, never global appearance.
private final class TransparentWindowBridge: NSView {
    /// Applies transparent title-bar and content settings when AppKit supplies the window.
    /// - Returns: Nothing; preserves standard traffic lights and the window shadow.
    fileprivate override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        window?.isOpaque = false
        window?.backgroundColor = .clear
        window?.titlebarAppearsTransparent = true
        window?.isMovableByWindowBackground = true
    }
}

/// A native behind-window blur that reveals real desktop content rather than an internal color field.
internal struct DesktopGlass: NSViewRepresentable {
    /// Creates an active visual-effect surface that samples behind the application window.
    /// - Parameter context: SwiftUI representable context.
    /// - Returns: A noninteractive native material view.
    internal func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = .underWindowBackground
        view.blendingMode = .behindWindow
        view.state = .active
        return view
    }

    /// Keeps the native material active across SwiftUI updates.
    /// - Parameters: nsView: Existing material view. context: SwiftUI representable context.
    /// - Returns: Nothing; reapplies the stable visual-effect state.
    internal func updateNSView(_ nsView: NSVisualEffectView, context: Context) { nsView.state = .active }
}

/// A non-authenticating privacy cover inspired by the approved landscape interlude.
internal struct LockedArtwork: View {
    internal let unlock: () -> Void

    internal var body: some View {
        GeometryReader { proxy in
            ZStack {
                LinearGradient(colors: [ControlTheme.sceneTop, ControlTheme.cloud, ControlTheme.sceneBottom], startPoint: .top, endPoint: .bottomTrailing)
                fortress(in: proxy.size)
                shore(in: proxy.size)
                dotField
                Button(action: unlock) {
                    Label(ControlConstants.unlockDisplay, systemImage: ControlConstants.unlockIcon)
                        .font(.system(size: 15, weight: .semibold)).padding(.horizontal, 22).padding(.vertical, 12)
                }.buttonStyle(.plain).foregroundStyle(ControlTheme.railInk)
                    .background(ControlTheme.rail.opacity(0.86), in: Capsule())
                    .overlay { Capsule().stroke(Color.white.opacity(0.23), lineWidth: 1) }
            }
            .clipShape(RoundedRectangle(cornerRadius: ControlTheme.cornerRadius, style: .continuous))
            .overlay { RoundedRectangle(cornerRadius: ControlTheme.cornerRadius, style: .continuous).stroke(Color.black.opacity(0.38), lineWidth: 2) }
        }
    }

    /// Builds the distant architectural silhouette without external image assets.
    /// - Parameter size: Current artwork bounds.
    /// - Returns: A layered, centered fortress silhouette.
    private func fortress(in size: CGSize) -> some View {
        HStack(alignment: .bottom, spacing: 7) {
            ForEach(0..<9, id: \.self) { index in
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(ControlTheme.ink.opacity(index.isMultiple(of: 2) ? 0.48 : 0.34))
                    .frame(width: size.width * 0.055, height: size.height * (0.16 + CGFloat((index * 3) % 5) * 0.035))
            }
        }.offset(y: size.height * 0.10).accessibilityHidden(true)
    }

    /// Adds a quiet foreground shoreline so the lock view reads as artwork, not a dialog.
    /// - Parameter size: Current artwork bounds.
    /// - Returns: An asymmetric, blurred foreground shape.
    private func shore(in size: CGSize) -> some View {
        UnevenRoundedRectangle(topLeadingRadius: size.width * 0.04, bottomLeadingRadius: size.width * 0.02,
            bottomTrailingRadius: size.width * 0.20, topTrailingRadius: size.width * 0.30, style: .continuous)
            .fill(ControlTheme.ink.opacity(0.34))
            .frame(width: size.width * 0.72, height: size.height * 0.20)
            .blur(radius: 3).offset(x: -size.width * 0.22, y: size.height * 0.35)
            .accessibilityHidden(true)
    }

    private var dotField: some View {
        Canvas { context, size in
            let spacing: CGFloat = 14
            var y: CGFloat = spacing
            while y < size.height {
                var x: CGFloat = spacing
                while x < size.width {
                    let diameter: CGFloat = Int((x + y) / spacing).isMultiple(of: 7) ? 2.1 : 1.25
                    context.fill(Path(ellipseIn: CGRect(x: x, y: y, width: diameter, height: diameter)), with: .color(Color.white.opacity(0.38)))
                    x += spacing
                }
                y += spacing
            }
        }.accessibilityHidden(true)
    }
}
