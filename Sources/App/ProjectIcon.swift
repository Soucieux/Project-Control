import AppKit
import SwiftUI

/// Reuses the preferred project-root application's macOS icon, never a companion's arbitrary brand.
internal struct ProjectIcon: View {
    internal let project: ProjectRecord
    internal let size: CGFloat

    internal var body: some View {
        Group {
            if let application = ApplicationLocator.preferred(project.applications.filter {
                ApplicationLocator.isCurrentCandidate($0, for: project)
            }, project: project.name, folder: project.folder) {
                Image(nsImage: NSWorkspace.shared.icon(forFile: application.path))
                    .resizable().interpolation(.high).scaledToFit()
            } else {
                Image(systemName: ControlConstants.projectIcon)
                    .resizable().scaledToFit().padding(size * 0.15).foregroundStyle(ControlTheme.signal)
            }
        }.frame(width: size, height: size).accessibilityHidden(true)
    }
}
