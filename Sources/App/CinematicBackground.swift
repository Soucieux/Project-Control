import AppKit
import SwiftUI

/// Makes the host window transparent so the edge-to-edge shell owns every visible pixel.
internal struct WindowTransparencyConfigurator: NSViewRepresentable {
    /// Creates a passive view that configures its containing window after attachment.
    /// - Parameter context: SwiftUI representable context.
    /// - Returns: A transparent AppKit bridge view.
    internal func makeNSView(context: Context) -> NSView { TransparentWindowBridge() }

    /// Keeps the bridge inert after the one-time window configuration.
    /// - Parameters:
    ///   - nsView: Existing bridge.
    ///   - context: SwiftUI representable context.
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

/// A restrained full-window scene whose light, clouds, and texture remain legible through glass.
private struct CinematicBackdrop: View {
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

/// Shared light artwork used by both the active detail pane and the privacy cover.
internal struct CinematicArtwork: View {
    internal var body: some View {
        GeometryReader { proxy in
            ZStack {
                CinematicBackdrop()
                fortress(in: proxy.size)
                shore(in: proxy.size)
                CinematicHalftone()
            }
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
}

/// Draws the lower-third dot field shared by the clear lock artwork and blurred detail background.
internal struct CinematicHalftone: View {
    internal var body: some View {
        Canvas { context, size in
            let spacing: CGFloat = 7
            let top = size.height * 0.50
            var x: CGFloat = spacing
            while x < size.width {
                let wave = sin((x / max(size.width, 1)) * .pi * 4) * size.height * 0.035
                let start = size.height * 0.54 + wave
                var y: CGFloat = top
                while y < size.height {
                    let depth = min(max((y - start) / max(size.height - start, 1), 0), 1)
                    if depth > 0 {
                        let phase = Int((x + y) / spacing)
                        let diameter = 0.95 + (depth * 1.65) + (phase.isMultiple(of: 13) ? 0.55 : 0)
                        let opacity = 0.12 + (depth * 0.30)
                        context.fill(
                            Path(ellipseIn: CGRect(x: x, y: y, width: diameter, height: diameter)),
                            with: .color(ControlTheme.sceneWater.opacity(opacity))
                        )
                    }
                    y += spacing
                }
                x += spacing
            }
        }
        .accessibilityHidden(true)
    }
}

/// Adds the denser full-frame dot-matrix texture reserved for the clear privacy artwork.
private struct CinematicLockTexture: View {
    internal var body: some View {
        Canvas { context, size in
            let spacing: CGFloat = 7
            var row = 0
            var y: CGFloat = spacing
            while y < size.height {
                var column = 0
                var x: CGFloat = spacing
                while x < size.width {
                    let phase = (column * 3) + (row * 5)
                    if !phase.isMultiple(of: 17) {
                        let horizontalPosition = x / max(size.width, 1)
                        let verticalPosition = y / max(size.height, 1)
                        let architecture = verticalPosition > 0.28 && verticalPosition < 0.72
                            && horizontalPosition > 0.22 && horizontalPosition < 0.78
                        let shoreline = verticalPosition >= 0.70
                        let diameter: CGFloat = phase.isMultiple(of: 13) ? 2.1 : 1.35
                        let color = architecture || shoreline
                            ? Color.white.opacity(0.30)
                            : ControlTheme.sceneWater.opacity(0.24)
                        let bounds = CGRect(x: x, y: y, width: diameter, height: diameter)
                        if phase.isMultiple(of: 19) {
                            context.fill(
                                Path(roundedRect: CGRect(x: x, y: y, width: diameter * 2.4,
                                    height: diameter), cornerRadius: diameter / 2),
                                with: .color(color)
                            )
                        } else {
                            context.fill(Path(ellipseIn: bounds), with: .color(color))
                        }
                    }
                    column += 1
                    x += spacing
                }
                row += 1
                y += spacing
            }
        }
        .accessibilityHidden(true)
    }
}

/// A non-authenticating privacy cover built from the same artwork as the normal detail pane.
internal struct LockedArtwork: View {
    internal let unlock: () -> Void

    internal var body: some View {
        ZStack {
            CinematicArtwork()
            CinematicLockTexture()
            Button(action: unlock) {
                Label(ControlConstants.unlockDisplay, systemImage: ControlConstants.unlockIcon)
                    .font(.system(size: 15, weight: .semibold)).padding(.horizontal, 22).padding(.vertical, 12)
            }.buttonStyle(.plain).foregroundStyle(ControlTheme.railInk)
                .background(ControlTheme.rail.opacity(0.86), in: Capsule())
                .overlay { Capsule().stroke(Color.white.opacity(0.23), lineWidth: 1) }
        }
    }
}
