import AppKit
import SwiftUI

/// Makes the host window transparent so the edge-to-edge shell owns every visible pixel.
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

/// A native in-window blur that visibly samples the cinematic scene beneath the content plane.
internal struct SceneGlass: NSViewRepresentable {
    /// Creates an active visual-effect surface that samples the application's own scenic backdrop.
    /// - Parameter context: SwiftUI representable context.
    /// - Returns: A noninteractive native material view.
    internal func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = .underWindowBackground
        view.blendingMode = .withinWindow
        view.state = .active
        return view
    }

    /// Keeps the native material active across SwiftUI updates.
    /// - Parameters: nsView: Existing material view. context: SwiftUI representable context.
    /// - Returns: Nothing; reapplies the stable visual-effect state.
    internal func updateNSView(_ nsView: NSVisualEffectView, context: Context) { nsView.state = .active }
}

/// A restrained full-window scene whose light, clouds, and texture remain legible through glass.
internal struct CinematicBackdrop: View {
    internal var body: some View {
        GeometryReader { proxy in
            ZStack {
                LinearGradient(
                    colors: [ControlTheme.sceneTop, ControlTheme.cloud, ControlTheme.sceneBottom],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                horizon(in: proxy.size)
                cloudCluster(in: proxy.size, leading: true)
                cloudCluster(in: proxy.size, leading: false)
                dotField
            }
        }
        .accessibilityHidden(true)
    }

    /// Places a softly contrasting horizon across the lower window so blur has spatial depth.
    /// - Parameter size: Current application bounds.
    /// - Returns: A broad, asymmetric ground-and-sky transition.
    private func horizon(in size: CGSize) -> some View {
        UnevenRoundedRectangle(
            topLeadingRadius: size.width * 0.18,
            bottomLeadingRadius: 0,
            bottomTrailingRadius: 0,
            topTrailingRadius: size.width * 0.30,
            style: .continuous
        )
        .fill(ControlTheme.sceneWater.opacity(0.32))
        .frame(width: size.width * 1.08, height: size.height * 0.33)
        .blur(radius: 26)
        .offset(x: size.width * 0.04, y: size.height * 0.37)
    }

    /// Builds a luminous cloud bank at one lower corner without an external image asset.
    /// - Parameters:
    ///   - size: Current application bounds.
    ///   - leading: True for the leading bank; false for the trailing bank.
    /// - Returns: A layered cluster with enough local contrast to remain visible through material.
    private func cloudCluster(in size: CGSize, leading: Bool) -> some View {
        ZStack {
            Capsule().fill(ControlTheme.cloud.opacity(0.54))
                .frame(width: size.width * 0.29, height: size.height * 0.10)
                .offset(y: size.height * 0.08)
            Ellipse().fill(ControlTheme.cloud.opacity(0.60))
                .frame(width: size.width * 0.15, height: size.height * 0.16)
                .offset(x: leading ? -size.width * 0.07 : size.width * 0.07, y: size.height * 0.01)
            Ellipse().fill(Color.white.opacity(0.30))
                .frame(width: size.width * 0.12, height: size.height * 0.13)
                .offset(x: leading ? size.width * 0.05 : -size.width * 0.05, y: -size.height * 0.01)
            Ellipse().fill(ControlTheme.sceneBottom.opacity(0.28))
                .frame(width: size.width * 0.20, height: size.height * 0.11)
                .offset(x: leading ? size.width * 0.10 : -size.width * 0.10, y: size.height * 0.09)
        }
        .blur(radius: 22)
        .offset(x: leading ? -size.width * 0.36 : size.width * 0.36, y: size.height * 0.40)
    }

    private var dotField: some View {
        Canvas { context, size in
            let spacing: CGFloat = 13
            var y: CGFloat = spacing
            while y < size.height {
                var x: CGFloat = spacing
                while x < size.width {
                    let phase = Int((x * 0.7 + y) / spacing)
                    let diameter: CGFloat = phase.isMultiple(of: 11) ? 2.0 : 1.0
                    let opacity = phase.isMultiple(of: 5) ? 0.24 : 0.10
                    context.fill(
                        Path(ellipseIn: CGRect(x: x, y: y, width: diameter, height: diameter)),
                        with: .color(ControlTheme.ink.opacity(opacity))
                    )
                    x += spacing
                }
                y += spacing
            }
        }
    }
}

/// A non-authenticating privacy cover inspired by the approved landscape interlude.
internal struct LockedArtwork: View {
    internal let unlock: () -> Void

    internal var body: some View {
        GeometryReader { proxy in
            ZStack {
                CinematicBackdrop()
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
            .overlay { RoundedRectangle(cornerRadius: ControlTheme.cornerRadius, style: .continuous).strokeBorder(Color.black.opacity(0.38), lineWidth: 2) }
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
