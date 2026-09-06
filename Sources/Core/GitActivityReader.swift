import Foundation
import CryptoKit

/// One completed read-only Git invocation with no shell or repository code execution.
private struct GitCommandOutput {
    fileprivate let status: Int32
    fileprivate let data: Data
}

/// Converts complete timestamp lists into fixed calendar-month activity buckets.
internal enum CommitActivityCalculator {
    /// Groups every valid timestamp while retaining invalid records in the overall total.
    /// - Parameters: timestamps: Complete loaded timestamp records. calendar: Calendar and time zone used for grouping.
    /// - Returns: Descending valid years, twelve counts per year, and the unfiltered record total.
    internal static func summarize(_ timestamps: [String], calendar: Calendar) -> CommitActivity {
        summarize(timestamps.map { GitCommitMetadata(timestamp: $0, projectIDs: []) }, calendar: calendar)
    }

    /// Groups valid timestamp metadata and records project participation for every calendar month.
    /// - Parameters: records: Complete loaded Git records. calendar: Calendar and time zone used for grouping.
    /// - Returns: Descending valid years, twelve total and per-project buckets, and the unfiltered record total.
    internal static func summarize(_ records: [GitCommitMetadata], calendar: Calendar) -> CommitActivity {
        var buckets: [Int: [Int]] = [:]
        var projectBuckets: [Int: [[String: Int]]] = [:]
        for record in records {
            guard let seconds = TimeInterval(record.timestamp), seconds.isFinite else { continue }
            let components = calendar.dateComponents([.year, .month], from: Date(timeIntervalSince1970: seconds))
            guard let year = components.year, year > 0,
                  let month = components.month, (1...ControlConstants.monthCount).contains(month) else { continue }
            var counts = buckets[year] ?? Array(repeating: 0, count: ControlConstants.monthCount)
            counts[month - 1] += 1
            buckets[year] = counts
            var distributions = projectBuckets[year]
                ?? Array(repeating: [:], count: ControlConstants.monthCount)
            let identities = record.projectIDs.isEmpty ? [ControlConstants.repositoryActivityID] : record.projectIDs
            for identity in identities { distributions[month - 1][identity, default: 0] += 1 }
            projectBuckets[year] = distributions
        }
        let years = buckets.keys.sorted(by: >).map {
            CommitActivityYear(year: $0, months: buckets[$0] ?? [],
                projectCounts: projectBuckets[$0] ?? Array(repeating: [:], count: ControlConstants.monthCount))
        }
        return CommitActivity(years: years, totalCount: records.count, available: true)
    }

    /// Maps an absolute monthly count to the fixed five-level visual scale.
    /// - Parameter count: Commit records assigned to one month.
    /// - Returns: An intensity index from zero through four.
    internal static func intensity(for count: Int) -> Int {
        switch count {
        case 1...4: 1
        case 5...9: 2
        case 10...14: 3
        case 15...: 4
        default: 0
        }
    }

    /// Distinguishes months strictly later than the current calendar month.
    /// - Parameters: year: Displayed year. month: One-based displayed month. date: Comparison instant. calendar: Calendar and time zone.
    /// - Returns: True only when the displayed month begins after the comparison month.
    internal static func isFuture(year: Int, month: Int, relativeTo date: Date, calendar: Calendar) -> Bool {
        let current = calendar.dateComponents([.year, .month], from: date)
        guard let currentYear = current.year, let currentMonth = current.month else { return false }
        return year > currentYear || (year == currentYear && month > currentMonth)
    }
}

/// Reads Git timestamps, changed paths, and ref identities through fixed read-only system-git arguments.
internal enum GitActivityReader {
    /// Loads every unique commit reachable from repository refs without reading messages, authors, or file contents.
    /// - Parameters: root: Selected repository root. projects: Registered top-level folders. calendar: Calendar and time zone used for grouping.
    /// - Returns: Complete monthly activity, or an explicit unavailable value when Git cannot read the repository.
    internal static func load(_ root: URL, projects: [ProjectRecord] = [],
                              calendar: Calendar = .autoupdatingCurrent) -> CommitActivity {
        guard let result = output(root, arguments: [ControlConstants.gitLog, ControlConstants.gitAll,
            ControlConstants.gitNoRenames, ControlConstants.gitNameOnly, ControlConstants.gitNullTerminated,
            ControlConstants.gitMergeFirstParent, ControlConstants.gitTimestampRecordFormat]),
              result.status == 0 else { return .unavailable }
        return CommitActivityCalculator.summarize(records(from: result.data, projects: projects), calendar: calendar)
    }

    /// Parses NUL-framed records without treating quoted or multiline filenames as commit metadata.
    /// - Parameters: data: Fixed-format system-Git bytes. projects: Registered folders eligible for path mapping.
    /// - Returns: One timestamp and deduplicated affected-project set for each complete Git record.
    internal static func records(from data: Data, projects: [ProjectRecord]) -> [GitCommitMetadata] {
        let identities = Dictionary(uniqueKeysWithValues: projects.map { ($0.folder.lastPathComponent, $0.id) })
        var records: [GitCommitMetadata] = []
        var timestamp: String?
        var projectIDs: Set<String> = []
        var expectsTimestamp = false
        var firstPath = false
        for field in data.split(separator: 0, omittingEmptySubsequences: false) {
            if field.isEmpty {
                if let timestamp { records.append(GitCommitMetadata(timestamp: timestamp, projectIDs: projectIDs)) }
                timestamp = nil
                projectIDs = []
                expectsTimestamp = true
                continue
            }
            if expectsTimestamp {
                timestamp = String(data: field, encoding: .utf8)
                expectsTimestamp = false
                firstPath = true
                continue
            }
            let path = firstPath && field.first == 10 ? field.dropFirst() : field[...]
            firstPath = false
            guard timestamp != nil,
                  let folder = path.split(separator: 47, maxSplits: 1).first,
                  let name = String(data: folder, encoding: .utf8),
                  let identity = identities[name] else { continue }
            projectIDs.insert(identity)
        }
        if let timestamp { records.append(GitCommitMetadata(timestamp: timestamp, projectIDs: projectIDs)) }
        return records
    }

    /// Captures all current ref object identities so polling notices repository-history changes cheaply.
    /// - Parameter root: Selected repository root.
    /// - Returns: Stable digest of current refs, or a stable unavailable marker.
    internal static func fingerprint(_ root: URL) -> String {
        guard let result = output(root, arguments: [ControlConstants.gitShowReference,
            ControlConstants.gitHead, ControlConstants.gitHashOnly]), result.status == 0 else {
            return ControlConstants.gitUnavailableFingerprint
        }
        return Data(SHA256.hash(data: result.data)).base64EncodedString()
    }

    /// Executes one fixed system-Git request directly, never through a shell.
    /// - Parameters: root: Repository passed as Git's working-directory argument. arguments: Trusted constant Git arguments.
    /// - Returns: Exit status and standard-output bytes, or nil when the executable cannot start.
    private static func output(_ root: URL, arguments: [String]) -> GitCommandOutput? {
        let process = Process()
        let pipe = Pipe()
        process.executableURL = URL(fileURLWithPath: ControlConstants.gitExecutable)
        process.arguments = [ControlConstants.gitCurrentDirectory, root.path] + arguments
        var environment = ProcessInfo.processInfo.environment
        environment[ControlConstants.gitNoLazyFetchEnvironment] = ControlConstants.gitEnvironmentEnabled
        environment[ControlConstants.gitAllowedProtocolsEnvironment] = ControlConstants.empty
        process.environment = environment
        process.standardOutput = pipe
        process.standardError = FileHandle.nullDevice
        do { try process.run() }
        catch { return nil }
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()
        return GitCommandOutput(status: process.terminationStatus, data: data)
    }
}
