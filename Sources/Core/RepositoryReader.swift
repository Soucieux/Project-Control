import Foundation
import CryptoKit

/// Loads bounded READMEs and app identity metadata; never reads source files or runs project commands.
internal enum RepositoryReader {
    /// Reads a bounded regular file as UTF-8, rejecting symlink destinations outside the root.
    /// - Parameters: url: README path. root: Allowed repository boundary.
    /// - Returns: The README text, or throws without touching source files.
    internal static func read(_ url: URL, within root: URL) throws -> String {
        guard contains(url, in: root) else { throw ControlFailure(message: ControlConstants.unsafeProject) }
        let values = try url.resourceValues(forKeys: [.isRegularFileKey, .fileSizeKey])
        guard values.isRegularFile == true, (values.fileSize ?? Int.max) <= ControlConstants.maxReadmeBytes else {
            throw ControlFailure(message: ControlConstants.readFailure)
        }
        let handle = try FileHandle(forReadingFrom: url)
        defer { try? handle.close() }
        let data = try handle.read(upToCount: ControlConstants.maxReadmeBytes + 1) ?? Data()
        guard data.count <= ControlConstants.maxReadmeBytes, let text = String(data: data, encoding: .utf8) else {
            throw ControlFailure(message: ControlConstants.readFailure)
        }
        return text
    }

    /// Checks canonical containment including symlink resolution.
    /// - Parameters: url: Candidate path. root: Repository root.
    /// - Returns: Whether the candidate is a descendant of the root.
    internal static func contains(_ url: URL, in root: URL) -> Bool {
        url.resolvingSymlinksInPath().standardizedFileURL.path.hasPrefix(
            root.resolvingSymlinksInPath().standardizedFileURL.path + ControlConstants.slash)
    }

    /// Builds a repository snapshot from its Projects table and corresponding READMEs.
    /// - Parameter root: User-selected local repository folder.
    /// - Returns: The complete snapshot, or an error for an invalid register.
    internal static func load(_ root: URL) throws -> RepositorySnapshot {
        let canonical = root.resolvingSymlinksInPath().standardizedFileURL
        let rootReadme = canonical.appendingPathComponent(ControlConstants.readme)
        var identities = [documentIdentity(rootReadme, within: canonical)]
        let document = try read(rootReadme, within: canonical)
        let sections = try ReadmeParser.validatedSections(document)
        let explicitlyMapped = sections.contains { $0.mapping != nil }
        let register = ReadmeParser.topicSections(sections, topic: .projects).filter {
            $0.mapping == .projects || (!explicitlyMapped && $0.title.lowercased() == ControlConstants.projectsHeading)
        }
        guard !register.isEmpty, register.allSatisfy({ ReadmeParser.tableHeaders($0.lines).count >= 2 }) else {
            throw ControlFailure(message: ControlConstants.invalidRepository)
        }
        var seen: Set<String> = []
        let projects = try register.flatMap { ReadmeParser.table($0.lines) }.compactMap { row -> ProjectRecord? in
            guard row.count >= 2,
                  let name = ReadmeParser.match(row[0], ControlConstants.linkPattern, group: 1),
                  let link = ReadmeParser.match(row[0], ControlConstants.linkPattern, group: 2),
                  let decoded = link.removingPercentEncoding else { throw ControlFailure(message: ControlConstants.invalidRepository) }
            let folder = canonical.appendingPathComponent(decoded).standardizedFileURL
            guard contains(folder, in: canonical), folder.deletingLastPathComponent() == canonical else {
                throw ControlFailure(message: ControlConstants.unsafeProject)
            }
            let identifier = folder.resolvingSymlinksInPath().standardizedFileURL.path
            guard seen.insert(identifier).inserted else { return nil }
            identities += projectFingerprint(folder, within: canonical)
            return project(name: name, folder: folder, scope: ReadmeParser.plain(row[1]), root: canonical)
        }
        return RepositorySnapshot(root: canonical, projects: projects, history: ReadmeParser.history(sections),
            readAt: Date(), fingerprint: identities,
            overview: ReadmeParser.overview(sections, fallback: ControlConstants.noRepositoryOverview))
    }

    /// Assembles a project while representing a missing README explicitly.
    /// - Parameters: name: Register label. folder: Local project folder. scope: Root summary. root: Trust boundary.
    /// - Returns: Presentation data with source availability flags.
    private static func project(name: String, folder: URL, scope: String, root: URL) -> ProjectRecord {
        let readme = folder.appendingPathComponent(ControlConstants.readme)
        let document = try? read(readme, within: root)
        var sections: [ReadmeSection] = []
        var warning: String?
        if let document {
            do { sections = try ReadmeParser.validatedSections(document) }
            catch { warning = ControlConstants.mappingFailure }
        } else { warning = ControlConstants.sourceUnavailable }
        let mapped = sections.contains { $0.mapping != nil }
        let introduction = (mapped
            ? ReadmeParser.paragraphs(ReadmeParser.topicSections(sections, topic: .overview)).first
            : ReadmeParser.paragraphs(Array(sections.prefix(2))).first) ?? (mapped ? ControlConstants.noIntroduction : scope)
        var isDirectory: ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: folder.path, isDirectory: &isDirectory)
        return ProjectRecord(id: folder.resolvingSymlinksInPath().standardizedFileURL.path, name: name, folder: folder, readme: readme,
            introduction: introduction.isEmpty ? ControlConstants.noIntroduction : introduction,
            version: ReadmeParser.release(sections, fallback: scope), architecture: ReadmeParser.architecture(sections), workflows: ReadmeParser.workflows(sections),
            history: ReadmeParser.history(sections), folderAvailable: exists && isDirectory.boolValue,
            readmeAvailable: document != nil,
            overview: ReadmeParser.overview(sections, fallback: introduction.isEmpty ? ControlConstants.noIntroduction : introduction),
            models: ReadmeParser.models(sections),
            applications: ApplicationLocator.candidates(in: folder).filter(ApplicationLocator.isApplication), sourceWarning: warning)
    }

    /// Captures bounded README digests and metadata so unchanged files need not be parsed.
    /// - Parameter snapshot: Last successful snapshot.
    /// - Returns: Ordered content/metadata identities, including missing or unreadable files.
    internal static func fingerprint(_ snapshot: RepositorySnapshot) -> [String] {
        [documentIdentity(snapshot.root.appendingPathComponent(ControlConstants.readme), within: snapshot.root)]
            + snapshot.projects.flatMap { projectFingerprint($0.folder, within: snapshot.root) }
    }

    /// Observes top-level app additions, removals, and metadata changes alongside README changes.
    /// - Parameters: folder: Registered project folder. root: Allowed repository boundary.
    /// - Returns: Pre-read identities, including incomplete bundles so repairs can be detected.
    private static func projectFingerprint(_ folder: URL, within root: URL) -> [String] {
        [identity(folder), documentIdentity(folder.appendingPathComponent(ControlConstants.readme), within: root)]
            + ApplicationLocator.candidates(in: folder).flatMap { application in
                [identity(application), String(ApplicationLocator.isApplication(application)),
                    identity(application.appendingPathComponent(ControlConstants.appContents)
                    .appendingPathComponent(ControlConstants.appInfo))]
            }
    }

    /// Detects content changes even when an editor preserves file size and modification time.
    /// - Parameters: url: README path. root: Allowed repository boundary.
    /// - Returns: Fresh metadata and a bounded content digest, or a stable unreadable marker.
    private static func documentIdentity(_ url: URL, within root: URL) -> String {
        let metadata = identity(url)
        guard let document = try? read(url, within: root) else { return metadata + ControlConstants.sourceUnavailable }
        return metadata + ControlConstants.joined + Data(SHA256.hash(data: Data(document.utf8))).base64EncodedString()
    }

    /// Reads fresh metadata before parsing so concurrent edits trigger a later refresh.
    /// - Parameter url: Folder or README whose identity is being observed.
    /// - Returns: Resolved path, modification time, and size, or a missing-file marker.
    private static func identity(_ url: URL) -> String {
        let path = url.resolvingSymlinksInPath().standardizedFileURL.path
        guard let values = try? FileManager.default.attributesOfItem(atPath: path),
              let date = values[.modificationDate] as? Date,
              let size = values[.size] as? NSNumber else { return path }
        return path + ControlConstants.joined + String(date.timeIntervalSinceReferenceDate) + ControlConstants.joined + size.stringValue
    }
}
