import Foundation

/// Discovers only top-level app bundles; no scripts, recursive build scans, or launch side effects.
internal enum ApplicationLocator {
    /// Finds visible app-shaped directories contained within the selected project.
    /// - Parameters:
    ///   - folder: Project folder from the register.
    ///   - root: Selected repository boundary.
    /// - Returns: Sorted, canonical candidates, including incomplete bundles for refresh tracking.
    internal static func candidates(in folder: URL, within root: URL) -> [URL] {
        guard RepositoryReader.contains(folder, in: root) else { return [] }
        let entries = (try? FileManager.default.contentsOfDirectory(at: folder,
            includingPropertiesForKeys: [.isDirectoryKey], options: [.skipsHiddenFiles])) ?? []
        let paths = entries.filter {
            $0.pathExtension.lowercased() == ControlConstants.appExtension
                && RepositoryReader.contains($0, in: folder)
                && (try? $0.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true
        }.map { $0.resolvingSymlinksInPath().standardizedFileURL }
        return Array(Set(paths)).sorted { $0.path < $1.path }
    }

    /// Rechecks the canonical project identity and containment without reading bundle metadata.
    /// - Parameters:
    ///   - url: Previously discovered bundle.
    ///   - project: Registered project with its canonical identity.
    /// - Returns: True only while the folder and bundle remain within that original project.
    internal static func isWithinCurrentProject(_ url: URL, for project: ProjectRecord) -> Bool {
        project.hasCurrentIdentity
            && url.resolvingSymlinksInPath().standardizedFileURL.path.hasPrefix(project.id + ControlConstants.slash)
    }

    /// Rechecks an automatic candidate against the project identity captured in the snapshot.
    /// - Parameters:
    ///   - url: Previously discovered bundle.
    ///   - project: Registered project with its canonical identity.
    /// - Returns: True only while the bundle remains within that original project and still has valid,
    ///   executable bundle metadata.
    internal static func isCurrentCandidate(_ url: URL, for project: ProjectRecord) -> Bool {
        isWithinCurrentProject(url, for: project) && isApplication(url)
    }

    /// Checks bundle identity and executable metadata without reading or executing code.
    /// - Parameter url: Automatic candidate or explicitly located app.
    /// - Returns: Whether the app has a contained, executable entry point and APPL identity.
    internal static func isApplication(_ url: URL) -> Bool {
        let info = url.appendingPathComponent(ControlConstants.appContents).appendingPathComponent(ControlConstants.appInfo)
            .resolvingSymlinksInPath()
        guard url.pathExtension.lowercased() == ControlConstants.appExtension,
              RepositoryReader.contains(info, in: url),
              let attributes = try? FileManager.default.attributesOfItem(atPath: info.path),
              attributes[.type] as? FileAttributeType == .typeRegular,
              let size = attributes[.size] as? NSNumber, size.intValue <= ControlConstants.maxReadmeBytes,
              let handle = try? FileHandle(forReadingFrom: info) else { return false }
        defer { try? handle.close() }
        // Bundle caches Info.plist across replacements, so validation must read fresh bounded metadata.
        guard let data = try? handle.read(upToCount: ControlConstants.maxReadmeBytes + 1),
              data.count <= ControlConstants.maxReadmeBytes,
              let metadata = (try? PropertyListSerialization.propertyList(from: data, options: [], format: nil)) as? NSDictionary,
              metadata[ControlConstants.bundleTypeKey] as? String == ControlConstants.bundleApplicationType,
              let name = metadata[ControlConstants.bundleExecutableKey] as? String,
              !name.isEmpty, (name as NSString).lastPathComponent == name else { return false }
        let executable = url.appendingPathComponent(ControlConstants.appContents)
            .appendingPathComponent(ControlConstants.appExecutableFolder).appendingPathComponent(name)
        guard RepositoryReader.contains(executable, in: url),
              let entry = try? FileManager.default.attributesOfItem(atPath: executable.resolvingSymlinksInPath().path),
              entry[.type] as? FileAttributeType == .typeRegular else { return false }
        return FileManager.default.isExecutableFile(atPath: executable.path)
    }

    /// Prefers a project-name match, then a folder-name match, then a sole remaining app.
    /// - Parameters:
    ///   - applications: Valid candidates.
    ///   - project: Register name.
    ///   - folder: Project folder.
    /// - Returns: The unambiguous target, or nil when a choice is needed.
    internal static func preferred(_ applications: [URL], project: String, folder: URL) -> URL? {
        for name in [project, folder.lastPathComponent] {
            let matches = applications.filter {
                $0.deletingPathExtension().lastPathComponent.caseInsensitiveCompare(name) == .orderedSame
            }
            if matches.count == 1 { return matches[0] }
        }
        return applications.count == 1 ? applications[0] : nil
    }
}
