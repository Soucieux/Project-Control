import Foundation

/// Reads a project's `CHANGELOG.md` into history entries and the periods its history strip draws, without
/// evaluating HTML, links or code.
internal enum ChangelogParser {
    /// Splits a changelog into its entries: one per second-level heading outside fenced samples, with the
    /// summary bullets under the heading and the lines of each third-level subsection.
    /// - Parameter markdown: Bounded changelog text.
    /// - Returns: The entries in source order, newest first as the file keeps them, bounded to the entry limit.
    internal static func entries(_ markdown: String) -> [HistoryEntry] {
        var result: [HistoryEntry] = []
        var title: String?
        var date: String?
        var summary: [String] = []
        var sections: [HistorySection] = []
        var sectionName: String?
        var sectionLines: [String] = []
        var fence: String?
        /// Closes the subsection being read, keeping it when it has a name.
        func closeSection() {
            if let name = sectionName { sections.append(HistorySection(name: name, lines: sectionLines)) }
            sectionName = nil
            sectionLines = []
        }
        /// Closes the entry being read, keeping it when it has a title.
        func closeEntry() {
            closeSection()
            if let title { result.append(HistoryEntry(title: title, lines: summary, date: date, sections: sections)) }
            title = nil
            date = nil
            summary = []
            sections = []
        }
        for line in markdown.components(separatedBy: .newlines) {
            if let current = fence {
                if let marker = ReadmeParser.match(line, ControlConstants.closingFencePattern, group: 1),
                   marker.first == current.first && marker.count >= current.count { fence = nil }
                continue
            }
            if let marker = ReadmeParser.match(line, ControlConstants.fencePattern, group: 1) {
                fence = marker
                continue
            }
            if let heading = ReadmeParser.match(line, ControlConstants.entryHeadingPattern, group: 1) {
                closeEntry()
                guard result.count < ControlConstants.maxChangelogEntries else { break }
                let plain = ReadmeParser.plain(heading)
                date = ReadmeParser.match(plain, ControlConstants.entryDatePattern, group: 1)
                title = date == nil ? plain : ReadmeParser.plain(replacingDate(in: plain))
                continue
            }
            guard title != nil else { continue }
            if let heading = ReadmeParser.match(line, ControlConstants.sectionHeadingPattern, group: 1) {
                closeSection()
                sectionName = ReadmeParser.plain(heading)
                continue
            }
            let text = ReadmeParser.plain(ReadmeParser.match(line, ControlConstants.listItemPattern, group: 1) ?? line)
            guard !text.isEmpty else { continue }
            if sectionName != nil { sectionLines.append(text) } else { summary.append(text) }
        }
        closeEntry()
        return result
    }

    /// Lays out the history strip: the entries of every period, years before the last twelve months and then
    /// each month, with the releases each period holds. The window counts back from the newest entry, so the
    /// strip changes only with the entries.
    /// - Parameter entries: The changelog's entries.
    /// - Returns: The strip, or nil when no entry carries a date.
    internal static func strip(_ entries: [HistoryEntry]) -> HistoryStrip? {
        let dated = entries.compactMap { entry -> (month: Int, entry: HistoryEntry)? in
            guard let date = entry.date, let month = monthIndex(date) else { return nil }
            return (month, entry)
        }
        guard let newest = dated.map(\.month).max(), let oldest = dated.map(\.month).min() else { return nil }
        let windowStart = newest - ControlConstants.monthCount + 1
        var counts: [Int: Int] = [:]
        var releases: [Int: [Version]] = [:]
        for (month, entry) in dated {
            let key = month >= windowStart ? month : (month / ControlConstants.monthCount) * ControlConstants.monthCount
            counts[key, default: 0] += 1
            if let version = release(entry.title) { releases[key, default: []].append(version) }
        }
        let yearKeys = counts.keys.filter { $0 < windowStart }
        var periods: [HistoryPeriod] = []
        if let firstYear = yearKeys.min(), let lastYear = yearKeys.max() {
            for year in stride(from: firstYear, through: lastYear, by: ControlConstants.monthCount) {
                periods.append(period(key: year, label: String(year / ControlConstants.monthCount), yearLabel: nil,
                    isMonth: false, counts: counts, releases: releases))
            }
        }
        let firstMonth = yearKeys.isEmpty ? oldest : windowStart
        for month in firstMonth...newest {
            let index = month % ControlConstants.monthCount
            let yearLabel = month == firstMonth || index == 0 ? String(month / ControlConstants.monthCount) : nil
            periods.append(period(key: month, label: ControlConstants.stripMonthLabels[index], yearLabel: yearLabel,
                isMonth: true, counts: counts, releases: releases))
        }
        let versions = releases.values.flatMap { $0 }.sorted()
        return HistoryStrip(periods: periods, span: spanText(oldest: oldest, newest: newest, monthsOnly: yearKeys.isEmpty),
            entries: dated.count, releases: versions.count,
            versionRange: versions.first.map { first in
                let last = versions[versions.count - 1]
                return first == last ? last.label : first.label + ControlConstants.versionArrow + last.label
            })
    }

    /// A release's major and minor numbers, ordered numerically.
    internal struct Version: Comparable {
        internal let major: Int
        internal let minor: Int
        /// The version as it is shown, `v<major>.<minor>`.
        internal var label: String {
            ControlConstants.versionPrefix + String(major) + ControlConstants.versionSeparator + String(minor)
        }

        /// Orders versions by major, then minor number.
        /// - Parameters:
        ///   - lhs: One version.
        ///   - rhs: Another.
        /// - Returns: Whether the first comes before the second.
        internal static func < (lhs: Version, rhs: Version) -> Bool {
            (lhs.major, lhs.minor) < (rhs.major, rhs.minor)
        }
    }

    /// Builds one strip cell.
    /// - Parameters:
    ///   - key: The period's month index, or the index of a year's first month.
    ///   - label: The text above the cell.
    ///   - yearLabel: The calendar year shown over the cell, or nil.
    ///   - isMonth: Whether the cell is a month rather than a year.
    ///   - counts: Entries per period key.
    ///   - releases: Release versions per period key.
    /// - Returns: The cell, empty when the period holds no entry.
    private static func period(key: Int, label: String, yearLabel: String?, isMonth: Bool,
                               counts: [Int: Int], releases: [Int: [Version]]) -> HistoryPeriod {
        let versions = releases[key] ?? []
        return HistoryPeriod(id: String(key), label: label, yearLabel: yearLabel, isMonth: isMonth,
            entries: counts[key] ?? 0, releases: versions.count, latestVersion: versions.max()?.label)
    }

    /// Reads a release version from an entry title of the form `v6.4 / build 64` or `Observatory v3.3`.
    /// - Parameter title: The entry's title without its date.
    /// - Returns: The version, or nil for a title that is not a release.
    internal static func release(_ title: String) -> Version? {
        guard let major = ReadmeParser.match(title, ControlConstants.releaseTitlePattern, group: 1),
              let minor = ReadmeParser.match(title, ControlConstants.releaseTitlePattern, group: 2),
              let majorNumber = Int(major), let minorNumber = Int(minor) else { return nil }
        return Version(major: majorNumber, minor: minorNumber)
    }

    /// Counts a date's month from year zero.
    /// - Parameter date: An ISO date, `YYYY-MM-DD`.
    /// - Returns: `year × 12 + month − 1`, or nil for another form.
    private static func monthIndex(_ date: String) -> Int? {
        guard ReadmeParser.match(date, ControlConstants.historyDatePattern) != nil,
              let year = Int(date.prefix(4)), let month = Int(date.dropFirst(5).prefix(2)),
              (1...ControlConstants.monthCount).contains(month) else { return nil }
        return year * ControlConstants.monthCount + month - 1
    }

    /// Removes the ` — YYYY-MM-DD` suffix of an entry heading.
    /// - Parameter heading: The plain heading.
    /// - Returns: The title alone.
    private static func replacingDate(in heading: String) -> String {
        guard let range = heading.range(of: ControlConstants.entryDatePattern, options: .regularExpression) else { return heading }
        return String(heading[..<range.lowerBound])
    }

    /// Writes the strip's date span.
    /// - Parameters:
    ///   - oldest: The oldest entry's month index.
    ///   - newest: The newest entry's month index.
    ///   - monthsOnly: Whether every period is a month, so the span names months.
    /// - Returns: `2021 – 2026`, `Aug – Oct 2026`, `Sep 2026` or `Aug 2025 – Oct 2026`.
    private static func spanText(oldest: Int, newest: Int, monthsOnly: Bool) -> String {
        let (oldYear, oldMonth) = (oldest / ControlConstants.monthCount, oldest % ControlConstants.monthCount)
        let (newYear, newMonth) = (newest / ControlConstants.monthCount, newest % ControlConstants.monthCount)
        let labels = ControlConstants.stripMonthLabels
        if !monthsOnly {
            return oldYear == newYear ? String(oldYear) : String(oldYear) + ControlConstants.spanDash + String(newYear)
        }
        if oldest == newest { return labels[oldMonth] + ControlConstants.space + String(newYear) }
        if oldYear == newYear {
            return labels[oldMonth] + ControlConstants.spanDash + labels[newMonth] + ControlConstants.space + String(newYear)
        }
        return labels[oldMonth] + ControlConstants.space + String(oldYear) + ControlConstants.spanDash
            + labels[newMonth] + ControlConstants.space + String(newYear)
    }
}
