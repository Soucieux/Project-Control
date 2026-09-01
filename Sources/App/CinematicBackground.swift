import SwiftUI

/// Soft landscape color fields remain visible through the native material surface.
internal struct CinematicBackdrop: View {
    internal var body: some View {
        GeometryReader { proxy in
            ZStack {
                LinearGradient(colors: [ControlTheme.sceneTop, ControlTheme.sceneBottom], startPoint: .topLeading, endPoint: .bottomTrailing)
                Ellipse().fill(ControlTheme.cloud.opacity(0.78))
                    .frame(width: proxy.size.width * 0.62, height: proxy.size.height * 0.33)
                    .blur(radius: 54).offset(x: -proxy.size.width * 0.22, y: proxy.size.height * 0.34)
                Ellipse().fill(Color.white.opacity(0.42))
                    .frame(width: proxy.size.width * 0.48, height: proxy.size.height * 0.27)
                    .blur(radius: 60).offset(x: proxy.size.width * 0.30, y: -proxy.size.height * 0.33)
                Ellipse().fill(Color(red: 0.35, green: 0.54, blue: 0.54).opacity(0.28))
                    .frame(width: proxy.size.width * 0.48, height: proxy.size.height * 0.43)
                    .blur(radius: 72).offset(x: proxy.size.width * 0.34, y: proxy.size.height * 0.26)
            }
        }.ignoresSafeArea().accessibilityHidden(true)
    }
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
                VStack(spacing: 14) {
                    Button(action: unlock) {
                        Label(ControlConstants.unlockDisplay, systemImage: ControlConstants.unlockIcon)
                            .font(.system(size: 15, weight: .semibold)).padding(.horizontal, 22).padding(.vertical, 12)
                    }.buttonStyle(.plain).foregroundStyle(ControlTheme.railInk)
                        .background(ControlTheme.rail.opacity(0.86), in: Capsule())
                        .overlay { Capsule().stroke(Color.white.opacity(0.23), lineWidth: 1) }
                    Text(ControlConstants.lockedArtwork).font(.caption).foregroundStyle(ControlTheme.ink.opacity(0.62))
                }
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
