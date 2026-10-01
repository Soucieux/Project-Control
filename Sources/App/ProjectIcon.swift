import AppKit
import SwiftUI

/// Shows the project folder's own Finder icon, the artwork each project folder carries.
internal struct ProjectIcon: View {
    internal let project: ProjectRecord
    internal let size: CGFloat

    internal var body: some View {
        Group {
            if project.folderAvailable && project.hasCurrentIdentity {
                Image(nsImage: FolderIcons.icon(for: project))
                    .resizable().interpolation(.high).scaledToFit()
            } else {
                Image(systemName: ControlConstants.projectIcon)
                    .resizable().scaledToFit().padding(size * 0.15).foregroundStyle(ControlTheme.signal)
            }
        }.frame(width: size, height: size).accessibilityHidden(true)
    }
}

/// Project folder icons, fetched once for each state of their folder. Looking up a folder's custom Finder icon
/// costs about a fifth of a millisecond and the rail alone shows one icon per project, while reading the folder's
/// stamp costs about an eighth of that, so a folder whose stamp is unchanged reuses the icon fetched last.
internal enum FolderIcons {
    /// The icon last fetched for each project folder, with the stamp the folder had then.
    private static let fetched = NSCache<NSString, FetchedIcon>()

    /// Returns a project folder's Finder icon, fetching it again only when the folder has changed since.
    /// - Parameter project: A project whose folder still resolves to its snapshot identity.
    /// - Returns: The folder's current icon.
    internal static func icon(for project: ProjectRecord) -> NSImage {
        let key = project.folder.path as NSString
        let stamp = FolderStamp(project)
        if let stamp, let entry = fetched.object(forKey: key), entry.stamp == stamp { return entry.image }
        let image = NSWorkspace.shared.icon(forFile: project.folder.path)
        if let stamp { fetched.setObject(FetchedIcon(stamp: stamp, image: image), forKey: key) }
        return image
    }
}

/// What a project folder's icon depends on: the folder the project resolves to, and when that folder's and its
/// custom icon file's metadata last changed. Setting, replacing or removing a custom icon, rewriting the icon file
/// in place and a folder-only change such as a Finder colour label each move one of these times, and a time of
/// this kind also moves whenever the item's content does.
private struct FolderStamp: Equatable {
    private let identity: String
    private let folderChanged: Date
    private let iconChanged: Date?

    /// Reads the times through fresh URLs, because a URL keeps the resource values it has already read.
    /// - Parameter project: A project whose folder still resolves to its snapshot identity.
    /// - Returns: The stamp, or nil when the folder's times cannot be read.
    internal init?(_ project: ProjectRecord) {
        let folder = URL(fileURLWithPath: project.id)
        guard let folderChanged = Self.changed(folder) else { return nil }
        identity = project.id
        self.folderChanged = folderChanged
        iconChanged = Self.changed(folder.appendingPathComponent(ControlConstants.customIconFile))
    }

    /// Reads when an item's metadata or content last changed.
    /// - Parameter item: The item's location.
    /// - Returns: Its attribute-change time, or nil when the item is missing or cannot be read.
    private static func changed(_ item: URL) -> Date? {
        (try? item.resourceValues(forKeys: [.attributeModificationDateKey]))?.attributeModificationDate
    }
}

/// A fetched folder icon and the stamp its folder had when it was fetched.
private final class FetchedIcon {
    internal let stamp: FolderStamp
    internal let image: NSImage

    /// Records one fetch.
    /// - Parameters:
    ///   - stamp: The folder's stamp at the fetch.
    ///   - image: The icon fetched.
    /// - Returns: The entry to keep.
    internal init(stamp: FolderStamp, image: NSImage) {
        self.stamp = stamp
        self.image = image
    }
}
