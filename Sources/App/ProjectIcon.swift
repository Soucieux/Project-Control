import AppKit
import SwiftUI

/// Shows the project folder's own Finder icon, the artwork each project folder carries.
internal struct ProjectIcon: View {
    internal let project: ProjectRecord
    internal let size: CGFloat

    internal var body: some View {
        Group {
            if project.folderAvailable && project.hasCurrentIdentity {
                Image(nsImage: NSWorkspace.shared.icon(forFile: project.folder.path))
                    .resizable().interpolation(.high).scaledToFit()
            } else {
                Image(systemName: ControlConstants.projectIcon)
                    .resizable().scaledToFit().padding(size * 0.15).foregroundStyle(ControlTheme.signal)
            }
        }.frame(width: size, height: size).accessibilityHidden(true)
    }
}
