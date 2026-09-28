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

/// The lock artwork's soft full-window scene: a gradient sky, a blurred horizon, two blurred cloud clusters and a
/// faint dot field.
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
                        with: .color(ControlTheme.sceneInk.opacity(opacity))
                    )
                    x += spacing
                }
                y += spacing
            }
        }
    }
}

/// The privacy cover's light artwork: the soft scene, a distant fortress, a foreground shore and the halftone.
private struct CinematicArtwork: View {
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
                    .fill(ControlTheme.sceneInk.opacity(index.isMultiple(of: 2) ? 0.48 : 0.34))
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
            .fill(ControlTheme.sceneInk.opacity(0.34))
            .frame(width: size.width * 0.72, height: size.height * 0.20)
            .blur(radius: 3).offset(x: -size.width * 0.22, y: size.height * 0.35)
            .accessibilityHidden(true)
    }
}

/// Draws the lock artwork's sage dot field, confined to the lower half and fading out upward.
private struct CinematicHalftone: View {
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

/// The detail surface's backdrop: a clear sky with pixel-dithered cloud banks in the lower corners, drawn
/// crisp so the glass above it has something to sample. The caller anchors it to the window, so the
/// clouds stay put while the rail opens and closes over them.
internal struct SkyBackdrop: View {
    /// One round puff of a cloud bank, placed inwards and upwards from the bank's corner, in points.
    private struct Puff {
        internal let x: CGFloat
        internal let y: CGFloat
        internal let radius: CGFloat
    }

    /// A wide base of low puffs, a middle tier, and smaller domes on top, as a cumulus bank.
    private static let leadingBank = [
        Puff(x: 40, y: 10, radius: 190), Puff(x: 200, y: 0, radius: 150), Puff(x: 330, y: -20, radius: 110),
        Puff(x: 430, y: -40, radius: 80), Puff(x: 70, y: 170, radius: 120), Puff(x: 190, y: 140, radius: 100),
        Puff(x: 110, y: 260, radius: 80), Puff(x: 30, y: 270, radius: 90)
    ]
    private static let trailingBank = [
        Puff(x: 40, y: 20, radius: 200), Puff(x: 220, y: 10, radius: 170), Puff(x: 380, y: -10, radius: 130),
        Puff(x: 500, y: -30, radius: 90), Puff(x: 80, y: 190, radius: 150), Puff(x: 220, y: 170, radius: 120),
        Puff(x: 330, y: 120, radius: 100), Puff(x: 120, y: 330, radius: 100), Puff(x: 40, y: 360, radius: 110),
        Puff(x: 210, y: 290, radius: 80)
    ]
    /// A 4×4 ordered-dither matrix scaled into 0...1, which breaks tone boundaries into pixels.
    private static let dither: [CGFloat] = [0, 8, 2, 10, 12, 4, 14, 6, 3, 11, 1, 9, 15, 7, 13, 5].map { ($0 + 0.5) / 16 }
    /// Each bank's pixels, measured from its corner. They are worked out once and moved with the corner, so a
    /// resize only moves them and the clouds keep every pixel.
    private static let leadingTones = tones(leadingBank, leading: true)
    private static let trailingTones = tones(trailingBank, leading: false)

    internal var body: some View {
        ZStack {
            LinearGradient(colors: [ControlTheme.skyTop, ControlTheme.skyBottom], startPoint: .top, endPoint: .bottom)
            Canvas { context, size in
                for (tones, corner) in [(Self.leadingTones, CGPoint(x: 0, y: size.height)),
                                        (Self.trailingTones, CGPoint(x: size.width, y: size.height))] {
                    var bank = context
                    bank.translateBy(x: corner.x, y: corner.y)
                    bank.fill(tones[0], with: .color(ControlTheme.cloudShade))
                    bank.fill(tones[1], with: .color(ControlTheme.cloudMid))
                    bank.fill(tones[2], with: .color(ControlTheme.cloudLight))
                }
            }
        }
        .accessibilityHidden(true)
    }

    /// Works out one bank's pixels as shade, middle and light tone paths. The puffs merge into one soft
    /// field, so the bank has a single bumpy outline; a pixel is lit where the field thins just above it,
    /// shaded towards the bank's base, and the outline is dithered so the edge breaks into single pixels.
    /// - Parameters:
    ///   - puffs: The bank's puffs, measured from its corner.
    ///   - leading: True for the lower-leading corner, false for the lower-trailing one.
    /// - Returns: Shade, middle and light paths, in that order, measured from the bank's corner, which is their
    ///   origin; the bank lies above it and inside the canvas.
    private static func tones(_ puffs: [Puff], leading: Bool) -> [Path] {
        let pixel = ControlTheme.cloudPixel
        let outline: CGFloat = 0.5
        let inwards: CGFloat = leading ? 1 : -1
        let centers = puffs.map { puff in (CGPoint(x: inwards * puff.x, y: -puff.y), puff.radius) }
        /// The merged field at a point: each puff adds a smooth bump that falls to zero at its radius.
        /// - Parameters:
        ///   - x: Horizontal position from the bank's corner.
        ///   - y: Vertical position from the bank's corner, negative above it.
        /// - Returns: The summed field; the cloud's outline is where it crosses `outline`.
        func field(_ x: CGFloat, _ y: CGFloat) -> CGFloat {
            centers.reduce(0) { total, puff in
                let dx = x - puff.0.x
                let dy = y - puff.0.y
                let bump = max(0, 1 - (dx * dx + dy * dy) / (puff.1 * puff.1))
                return total + bump * bump
            }
        }
        let left = leading ? 0 : centers.map { $0.0.x - $0.1 }.min() ?? 0
        let right = leading ? centers.map { $0.0.x + $0.1 }.max() ?? 0 : 0
        let top = centers.map { $0.0.y - $0.1 }.min() ?? 0
        let height = max(-top, 1)
        var tones = [Path(), Path(), Path()]
        var y = (top / pixel).rounded(.down) * pixel
        while y < 0 {
            var x = (left / pixel).rounded(.down) * pixel
            while x < right {
                let centerX = x + pixel / 2
                let centerY = y + pixel / 2
                let density = field(centerX, centerY)
                let column = (Int(x / pixel) % 4 + 4) % 4
                let row = (Int(y / pixel) % 4 + 4) % 4
                let threshold = dither[column + row * 4]
                if density > outline || density > outline * (0.55 + 0.45 * threshold) {
                    let lit = min(max((density - field(centerX, centerY - pixel * 4)) / 0.45, 0), 1)
                    let depth = (centerY - top) / height
                    let tone = 0.42 + lit * 0.75 - depth * 0.28 + (threshold - 0.5) * 0.30
                    let square = CGRect(x: x + 0.4, y: y + 0.4, width: pixel - 0.8, height: pixel - 0.8)
                    tones[tone > 0.55 ? 2 : tone > 0.25 ? 1 : 0].addRect(square)
                }
                x += pixel
            }
            y += pixel
        }
        return tones
    }
}

/// A non-authenticating privacy cover: the lock artwork under its dot-matrix texture, with Unlock at the center.
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
