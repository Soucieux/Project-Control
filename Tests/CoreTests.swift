import Foundation

/// Focused executable checks, intentionally independent of the UI and other subprojects.
@main
internal enum CoreTests {
    private static var count = 0

    /// Checks parser, local storage, refresh, and path boundaries with disposable fixtures.
    /// - Returns: Nothing; exits unsuccessfully on the first failed check or thrown error.
    internal static func main() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(TestConstants.rootName + UUID().uuidString)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }
        if CommandLine.arguments.contains(TestConstants.activityOnly) {
            try commitActivityChecks(root)
            print(TestConstants.passed + String(count))
            return
        }
        if CommandLine.arguments.contains(TestConstants.classificationOnly) {
            try classificationChecks(root)
            liveTechnologyChecks(try RepositoryReader.load(URL(fileURLWithPath: TestConstants.liveRoot)),
                register: try TestFixtures.registerRows(in: URL(fileURLWithPath: TestConstants.liveRoot)))
            print(TestConstants.passed + String(count))
            return
        }
        let repository = root.appendingPathComponent(ControlConstants.appName)
        let project = repository.appendingPathComponent(TestConstants.project)
        try FileManager.default.createDirectory(at: project, withIntermediateDirectories: true)
        let rootReadme = repository.appendingPathComponent(ControlConstants.readme)
        let projectReadme = project.appendingPathComponent(ControlConstants.readme)
        try TestConstants.rootReadme.write(to: rootReadme, atomically: true, encoding: .utf8)
        try TestConstants.projectReadme.write(to: projectReadme, atomically: true, encoding: .utf8)
        let snapshot = try RepositoryReader.load(repository)
        let record = snapshot.projects[0]
        check(snapshot.projects.count == 2, TestConstants.checkRegister)
        check(record.introduction == TestConstants.introduction, TestConstants.checkIntro)
        check(record.version == TestConstants.version, TestConstants.checkVersion)
        check(TestFixtures.text(record.architecture).contains(TestConstants.architecture), TestConstants.checkArchitecture)
        check(record.workflows.count == 2 && record.workflows[0].steps.count == 3, TestConstants.checkRoutes)
        check(!ReadmeParser.sections(TestConstants.projectReadme).flatMap(\.lines).joined().contains(TestConstants.forbidden), TestConstants.checkCode)
        check(record.history.first?.detail == TestConstants.history, TestConstants.checkHistory)
        check(snapshot.history.count == 1 && snapshot.history[0].title == TestConstants.project, TestConstants.checkRootHistory)
        check(snapshot.overview.first?.text == TestConstants.repositoryOverview, TestConstants.checkRepositoryOverview)
        check(!snapshot.projects[1].readmeAvailable && !snapshot.projects[1].folderAvailable, TestConstants.checkMissing)
        let fingerprint = RepositoryReader.fingerprint(snapshot)
        try TestConstants.updatedReadme.write(to: projectReadme, atomically: true, encoding: .utf8)
        check(RepositoryReader.fingerprint(snapshot) != fingerprint, TestConstants.checkChange)
        check(RepositoryReader.fingerprint(snapshot) != snapshot.fingerprint, TestConstants.checkCaptured)
        check(try RepositoryReader.load(repository).projects[0].introduction == TestConstants.updatedIntroduction, TestConstants.checkReload)
        try storageChecks(root)
        try applicationChecks(repository, project: project, root: root)
        let beforeRootEdit = RepositoryReader.fingerprint(snapshot)
        try TestConstants.rootReadme.replacingOccurrences(of: TestConstants.repositoryOverview, with: TestConstants.updatedRepositoryOverview)
            .write(to: rootReadme, atomically: true, encoding: .utf8)
        let refreshedRoot = try RepositoryReader.load(repository)
        check(RepositoryReader.fingerprint(snapshot) != beforeRootEdit
            && refreshedRoot.overview.first?.text == TestConstants.updatedRepositoryOverview, TestConstants.checkRepositoryOverviewRefresh)
        try TestConstants.escapedRoot.write(to: rootReadme, atomically: true, encoding: .utf8)
        checkThrows(TestConstants.checkEscape) { _ = try RepositoryReader.load(repository) }
        try TestConstants.symlinkRoot.write(to: rootReadme, atomically: true, encoding: .utf8)
        let outside = root.appendingPathComponent(TestConstants.external)
        try TestConstants.projectReadme.write(to: outside, atomically: true, encoding: .utf8)
        try FileManager.default.removeItem(at: projectReadme)
        try FileManager.default.createSymbolicLink(at: projectReadme, withDestinationURL: outside)
        check(try !RepositoryReader.load(repository).projects[0].readmeAvailable, TestConstants.checkSymlink)
        check(ReadmeParser.sections(TestConstants.tildeCode).count == 3, TestConstants.checkTilde)
        parserChecks()
        tableChecks()
        architectureHistoryChecks()
        try commitActivityChecks(root)
        try mappingChecks(root)
        try discoveryChecks(root)
        try classificationChecks(root)
        try aliasChecks(repository, project: project, outside: outside)
        let live = try RepositoryReader.load(URL(fileURLWithPath: TestConstants.liveRoot))
        let register = try TestFixtures.registerRows(in: URL(fileURLWithPath: TestConstants.liveRoot))
        check(live.projects.filter(\.isRegistered).map(\.name) == register.map(\.name), TestConstants.checkLive)
        let liveFolders = try FileManager.default.contentsOfDirectory(at: URL(fileURLWithPath: TestConstants.liveRoot),
            includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]).filter {
            FileManager.default.fileExists(atPath: $0.appendingPathComponent(ControlConstants.readme).path)
        }.map { $0.resolvingSymlinksInPath().standardizedFileURL.path }
        check(Set(liveFolders).isSubset(of: Set(live.projects.map(\.id))), TestConstants.checkLiveDiscovery)
        liveTechnologyChecks(live, register: register)
        check(live.projects.first { $0.name == ControlConstants.appName }?.workflows.count == 4,
            "Project Control shows four documented routes without turning parser guidance into a workflow")
        let categories = registerCategories(register)
        let registeredGroups = live.categories.filter { $0.projects.contains(where: \.isRegistered) }
        check(registeredGroups.map(\.name) == categories
            && registeredGroups.map { $0.projects.filter(\.isRegistered).count }
                == categories.map { name in register.filter { $0.category == name }.count },
            TestConstants.checkLiveCategories)
        check(live.projects.first { $0.name == TestConstants.liveProject }?.workflows.count == 6, TestConstants.checkLiveFlows)
        let liveModels = live.projects.first { $0.name == TestConstants.liveProject }?.models ?? []
        check(liveModels.contains { $0.table != nil }
            && !liveModels.contains { $0.text.contains(TestConstants.rawTableSeparator) || $0.text.hasPrefix(ControlConstants.pipe) }, TestConstants.checkLiveTables)
        for project in live.projects {
            check(project.sourceWarning == nil, TestConstants.checkSourceMapping + project.name)
            check(!project.workflows.isEmpty && !project.history.isEmpty, TestConstants.checkLiveCompleteness + project.name)
            let categories = project.architecture.enumerated().filter {
                $0.element.kind == .heading && TestConstants.architectureGroupTitles.contains($0.element.text)
            }
            let expected = (TestConstants.architectureGroupOrder[project.name] ?? []).map { TestConstants.architectureGroupTitles[$0] }
            check(categories.map { $0.element.text } == expected, TestConstants.checkArchitectureGroups + project.name)
            for category in categories {
                let next = category.offset + 1
                let table = next < project.architecture.count ? project.architecture[next].table : nil
                check(table?.headers.count == 2 && table?.rows.isEmpty == false,
                      TestConstants.checkArchitectureGroupTable + project.name + ControlConstants.joined + category.element.text)
            }
            let rows = project.architecture.compactMap(\.table).flatMap(\.rows)
            for term in TestConstants.technologyNames[project.name] ?? [] {
                check(rows.filter { $0.first == term }.count == 1, TestConstants.checkTechnologyRows + term)
            }
            check(!rows.isEmpty, TestConstants.checkAllArchitecture + project.name)
            for component in TestConstants.architectureCoverage[project.name] ?? [] {
                check(rows.contains { $0.joined(separator: ControlConstants.space).contains(component) },
                      TestConstants.checkArchitectureCoverage + project.name + ControlConstants.joined + component)
            }
        }
        print(TestConstants.passed + String(count))
    }

    /// Checks unfiltered totals, valid-month grouping, fixed intensity, future handling, and live Git loading.
    /// - Parameter root: Disposable non-Git directory used to exercise the unavailable state.
    /// - Returns: Nothing; terminates on an activity calculation or read-boundary regression.
    private static func commitActivityChecks(_ root: URL) throws {
        var calendar = Calendar(identifier: .gregorian)
        guard let timeZone = TimeZone(secondsFromGMT: 0),
              let now = ISO8601DateFormatter().date(from: TestConstants.activityNow) else {
            fatalError(TestConstants.checkActivityFuture)
        }
        calendar.timeZone = timeZone
        let nonfinite = CommitActivityCalculator.summarize(timestampRecords(["nan", "inf", "-inf"]), calendar: calendar)
        check(nonfinite.totalCount == 3 && nonfinite.years.isEmpty,
            "nonfinite timestamps remain in the total without creating calendar buckets")
        let activity = CommitActivityCalculator.summarize(timestampRecords(TestConstants.activityTimestamps), calendar: calendar)
        check(activity.available && activity.totalCount == TestConstants.activityTimestamps.count,
            TestConstants.checkActivityTotal)
        check(activity.years.map(\.year) == [2026, 2024]
            && activity.yearCount == 2
            && activity.years.allSatisfy { $0.months.count == ControlConstants.monthCount },
            TestConstants.checkActivityYears)
        check(activity.years[1].months[0] == 2 && activity.years[1].months[4] == 1
            && activity.years[0].months[11] == 1, TestConstants.checkActivityMonths)
        check([0, 1, 4, 5, 9, 10, 14, 15, 99].map { CommitActivityCalculator.intensity(for: $0) }
            == [0, 1, 1, 2, 2, 3, 3, 4, 4],
            TestConstants.checkActivityIntensity)
        check(!CommitActivityCalculator.isFuture(year: 2026, month: 9, relativeTo: now, calendar: calendar)
            && CommitActivityCalculator.isFuture(year: 2026, month: 10, relativeTo: now, calendar: calendar)
            && !CommitActivityCalculator.isFuture(year: 2025, month: 12, relativeTo: now, calendar: calendar),
            TestConstants.checkActivityFuture)
        check(!GitActivityReader.load(root, calendar: calendar).available, TestConstants.checkActivityUnavailable)
        let liveRoot = URL(fileURLWithPath: TestConstants.liveRoot)
        guard let snapshot = try? RepositoryReader.load(liveRoot), let project = snapshot.projects.first else {
            fatalError(TestConstants.checkActivityDistribution)
        }
        let syntheticOutput = ControlConstants.gitRecordPrefix + TestConstants.activityTimestamps[0]
            + ControlConstants.gitRecordPrefix + ControlConstants.newline + project.folder.lastPathComponent
            + ControlConstants.slash + ControlConstants.readme + ControlConstants.gitRecordPrefix
            + ControlConstants.gitRecordPrefix + TestConstants.activityTimestamps[1]
            + ControlConstants.gitRecordPrefix + ControlConstants.newline + ControlConstants.readme
            + ControlConstants.gitRecordPrefix
        let records = GitActivityReader.records(from: Data(syntheticOutput.utf8), projects: snapshot.projects)
        let distributed = CommitActivityCalculator.summarize(records, calendar: calendar)
        check(records.count == 2 && records[0].projectIDs == [project.id] && records[1].projectIDs.isEmpty
            && distributed.years[0].projectCounts[0][project.id] == 1
            && distributed.years[0].projectCounts[0][ControlConstants.repositoryActivityID] == 1,
            TestConstants.checkActivityDistribution)
        let unusualFolder = "資料\t\n\""
        let unusualProject = ProjectRecord(id: unusualFolder, name: unusualFolder,
            folder: URL(fileURLWithPath: "/fixture/" + unusualFolder), readme: project.readme,
            introduction: ControlConstants.empty, version: nil, architecture: [], workflows: [], history: [],
            folderAvailable: true, readmeAvailable: true)
        var unusualBytes = Data(("\0" + TestConstants.activityTimestamps[0] + "\0\n"
            + unusualFolder + "/line\n\u{001E}123\0" + unusualFolder + "/").utf8)
        unusualBytes.append(0xFF)
        unusualBytes.append(contentsOf: Data("\0\0invalid\0".utf8))
        let unusualRecords = GitActivityReader.records(from: unusualBytes, projects: [unusualProject])
        check(unusualRecords.count == 2 && unusualRecords[0].projectIDs == [unusualProject.id]
            && unusualRecords[1].projectIDs.isEmpty,
            "NUL framing preserves Unicode, tabs, newlines, record markers, and invalid child-name bytes")
        try gitActivityFixtureChecks(root, calendar: calendar)
        let live = GitActivityReader.load(liveRoot, projects: snapshot.projects, calendar: calendar)
        check(live.available && live.totalCount > 0 && !live.years.isEmpty
            && live.years.flatMap(\.projectCounts).contains { !$0.isEmpty }
            && GitActivityReader.fingerprint(liveRoot) != ControlConstants.gitUnavailableFingerprint,
            TestConstants.checkActivityLive)
    }

    /// Exercises real Git framing, Unicode paths, merge attribution, and commits without changed paths.
    /// - Parameters:
    ///   - root: Disposable fixture parent.
    ///   - calendar: Fixed UTC calendar for deterministic counts.
    /// - Returns: Nothing; throws on fixture setup failure or terminates on a read regression.
    private static func gitActivityFixtureChecks(_ root: URL, calendar: Calendar) throws {
        let repository = root.appendingPathComponent("GitActivity")
        let folder = repository.appendingPathComponent("資料\t\n\"")
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let readme = repository.appendingPathComponent(ControlConstants.readme)
        try "base".write(to: readme, atomically: true, encoding: .utf8)
        try TestFixtures.git(["init", "--initial-branch=fixture-main"], in: repository)
        try TestFixtures.git(["add", "."], in: repository)
        try TestFixtures.git(["commit", "-m", "base"], in: repository)
        try TestFixtures.git(["checkout", "-b", "fixture-topic"], in: repository)
        try "topic".write(to: folder.appendingPathComponent("line\n\u{001E}123"),
            atomically: true, encoding: .utf8)
        try TestFixtures.git(["add", "."], in: repository)
        try TestFixtures.git(["commit", "-m", "topic"], in: repository)
        try TestFixtures.git(["checkout", "fixture-main"], in: repository)
        try "main".write(to: readme, atomically: true, encoding: .utf8)
        try TestFixtures.git(["add", "."], in: repository)
        try TestFixtures.git(["commit", "-m", "main"], in: repository)
        try TestFixtures.git(["merge", "--no-ff", "fixture-topic", "-m", "merge"], in: repository)
        try TestFixtures.git(["commit", "--allow-empty", "-m", "empty"], in: repository)
        let project = ProjectRecord(id: folder.path, name: folder.lastPathComponent,
            folder: folder, readme: folder.appendingPathComponent(ControlConstants.readme),
            introduction: ControlConstants.empty, version: nil, architecture: [], workflows: [], history: [],
            folderAvailable: true, readmeAvailable: false)
        let activity = GitActivityReader.load(repository, projects: [project], calendar: calendar)
        check(activity.available && activity.totalCount == 5 && activity.years.count == 1
            && activity.years[0].months[0] == 5 && activity.years[0].projectCounts[0][project.id] == 2
            && activity.years[0].projectCounts[0][ControlConstants.repositoryActivityID] == 3,
            "real Git preserves all five commits and attributes unusual paths in topic and merge commits")
    }

    /// Checks independent optional classifications, grouping, compatibility, and live register edits.
    /// - Parameter root: Isolated fixture parent; no source repository files are modified.
    /// - Returns: Nothing; fails on metadata, grouping, or identity regression.
    private static func classificationChecks(_ root: URL) throws {
        let repository = root.appendingPathComponent(TestConstants.classificationDirectory)
        try FileManager.default.createDirectory(at: repository, withIntermediateDirectories: true)
        let readme = repository.appendingPathComponent(ControlConstants.readme)
        try TestConstants.classifiedRoot.write(to: readme, atomically: true, encoding: .utf8)
        let snapshot = try RepositoryReader.load(repository)
        let first = snapshot.projects[0]
        check(first.classification == ProjectClassification(category: TestConstants.managementCategory,
            technicalScope: TestConstants.desktopScope, technologies: [TestConstants.swiftUI, TestConstants.readmeDriven]), TestConstants.checkClassification)
        check(snapshot.projects[1].classification == ProjectClassification(category: TestConstants.aiCategory,
            technicalScope: TestConstants.fullStackScope, technologies: TestConstants.hostedTechnologyTags), TestConstants.checkClassification)
        check(snapshot.projects[2].classification.technologies == TestConstants.literalTechnologyTags, TestConstants.checkTechnologyTags)
        check(snapshot.projects.count == 5 && snapshot.categories.map(\.name) == [TestConstants.managementCategory,
            TestConstants.aiCategory, ControlConstants.uncategorized] && snapshot.categories.map { $0.projects.count } == [1, 2, 2],
            TestConstants.checkClassificationGroups)
        check(snapshot.categories[1].projects.map(\.id) == Array(snapshot.projects[1...2]).map(\.id), TestConstants.checkClassificationGroups)
        check(snapshot.projects.suffix(2).allSatisfy { $0.classification == ProjectClassification() }, TestConstants.checkClassificationUnknown)
        let changed = TestConstants.classifiedRoot.replacingOccurrences(of: TestConstants.managementCategory, with: TestConstants.renamedCategory)
            .replacingOccurrences(of: TestConstants.readmeDriven, with: TestConstants.hostedAI)
        try changed.write(to: readme, atomically: true, encoding: .utf8)
        check(RepositoryReader.fingerprint(snapshot) != snapshot.fingerprint, TestConstants.checkClassificationRefresh)
        let refreshed = try RepositoryReader.load(repository)
        check(refreshed.projects.map(\.id) == snapshot.projects.map(\.id)
            && refreshed.categories[0].name == TestConstants.renamedCategory
            && refreshed.projects[0].classification.technologies == [TestConstants.swiftUI, TestConstants.hostedAI], TestConstants.checkClassificationRefresh)
        try TestConstants.classifiedRoot.replacingOccurrences(
            of: TestConstants.classifiedTagsCell, with: TestConstants.emptyClassifiedTagsCell)
            .write(to: readme, atomically: true, encoding: .utf8)
        let cleared = try RepositoryReader.load(repository)
        check(cleared.projects[0].classification == ProjectClassification(category: TestConstants.managementCategory,
            technicalScope: TestConstants.desktopScope), TestConstants.checkTechnologyRemoval)
        try TestConstants.legacyClassifiedRoot.replacingOccurrences(
            of: TestConstants.legacyScope, with: TestConstants.conflictingLegacyScope)
            .write(to: readme, atomically: true, encoding: .utf8)
        let compatible = try RepositoryReader.load(repository)
        check(compatible.projects[0].classification == ProjectClassification(category: TestConstants.managementCategory,
            technicalScope: TestConstants.desktopScope, technologies: [TestConstants.swiftUI, TestConstants.readmeDriven]),
            TestConstants.checkClassificationCompatibility)
        try TestConstants.legacyClassifiedRoot.replacingOccurrences(of: TestConstants.tagsHeader, with: TestConstants.ignoredTagsHeader)
            .write(to: readme, atomically: true, encoding: .utf8)
        let retiredColumn = try RepositoryReader.load(repository)
        check(retiredColumn.projects.allSatisfy { $0.classification.technologies.isEmpty }, TestConstants.checkLegacyAI)
        try TestConstants.mappedRoot.write(to: readme, atomically: true, encoding: .utf8)
        let legacy = try RepositoryReader.load(repository)
        check(legacy.projects[0].classification == ProjectClassification()
            && legacy.categories[0].name == ControlConstants.uncategorized, TestConstants.checkClassificationUnknown)
        let multipleTables = """
        ## Projects
        | Project | Scope | Category | Technologies |
        |---|---|---|---|
        | [First](First/) | First. | One | Swift |

        | Project | Scope | Technologies | Category |
        |---|---|---|---|
        | [Second](Second/) | Second. | Python | Two |
        | [Short](Short/) | <strong>Category:</strong> Must not override the present column |
        """
        try multipleTables.write(to: readme, atomically: true, encoding: .utf8)
        let tables = try RepositoryReader.load(repository)
        check(tables.projects[1].classification.category == "Two"
            && tables.projects[1].classification.technologies == ["Python"],
            "each register table retains its own column order")
        check(tables.projects[2].classification == ProjectClassification(),
            "a missing legacy cell stays blank rather than falling back to conflicting scope labels")
        let externalRow = """
        ## Projects
        | Project | Scope |
        |---|---|
        | [Inside](Inside/) | A project in this repository. |

        | Forked project | Scope |
        |---|---|
        | [Outside](https://example.test/owner/outside) | Work kept in its own repository. |
        """
        try externalRow.write(to: readme, atomically: true, encoding: .utf8)
        let external = try RepositoryReader.load(repository)
        check(external.projects.count == 1 && external.projects[0].name == "Inside",
            "a row linking to another repository is skipped, not read as a project")
        let escaping = externalRow.replacingOccurrences(
            of: "https://example.test/owner/outside", with: "../Outside/")
        try escaping.write(to: readme, atomically: true, encoding: .utf8)
        var refused = false
        do { _ = try RepositoryReader.load(repository) } catch { refused = true }
        check(refused, "a relative link escaping the repository is still refused")
    }

    /// Checks the real register's positive tags without inspecting project code or runtime state.
    /// - Parameters:
    ///   - snapshot: Read-only snapshot of the repository's documented metadata.
    ///   - register: The same register read independently of the app's parser.
    /// - Returns: Nothing; fails when any registered project's tags diverge from its register row.
    private static func liveTechnologyChecks(_ snapshot: RepositorySnapshot, register: [RegisterRow]) {
        let registered = snapshot.projects.filter(\.isRegistered)
        check(registered.count == register.count, TestConstants.checkLive)
        check(snapshot.categories.filter { $0.projects.contains(where: \.isRegistered) }.map(\.name)
            == registerCategories(register), TestConstants.checkLiveCategories)
        for project in registered {
            check(project.classification.technologies == register.first { $0.name == project.name }?.technologies,
                TestConstants.checkLiveTechnologyTags + project.name)
        }
    }

    /// Lists the register's categories in first-appearance order.
    /// - Parameter register: Register rows read independently of the app's parser.
    /// - Returns: Each category name once, in the order its first project appears.
    private static func registerCategories(_ register: [RegisterRow]) -> [String] {
        register.map(\.category).reduce(into: []) { names, name in
            if !names.contains(name) { names.append(name) }
        }
    }

    /// Exercises explicit routing, exclusions, renamed roots, deletion, and metadata-preserving edits.
    /// - Parameter root: Disposable fixture directory.
    /// - Returns: Nothing; fails on a content-contract regression.
    private static func mappingChecks(_ root: URL) throws {
        let sections = try ReadmeParser.validatedSections(TestConstants.mappedReadme)
        let architecture = ReadmeParser.architecture(sections)
        check(architecture.compactMap(\.table).flatMap(\.rows).compactMap(\.first) == TestConstants.mappedTechnologyNames,
              TestConstants.checkMapping)
        let renamed = try ReadmeParser.validatedSections(TestConstants.mappedReadme.replacingOccurrences(
            of: TestConstants.mappedHeading, with: TestConstants.renamedMappedHeading))
        check(TestFixtures.text(ReadmeParser.architecture(renamed)) == TestFixtures.text(architecture), TestConstants.checkMapping)
        check(ReadmeParser.overview(sections, fallback: ControlConstants.noIntroduction).first?.text == TestConstants.introduction,
              TestConstants.checkMapping)
        check(ReadmeParser.models(sections).compactMap(\.table).flatMap(\.rows).first?.first == TestConstants.modelName,
              TestConstants.checkMapping)
        check(ReadmeParser.workflows(sections).first?.steps == TestConstants.mixedSteps, TestConstants.checkMapping)
        check(ReadmeParser.history(sections).first?.detail == TestConstants.history, TestConstants.checkMapping)
        check(ReadmeParser.release(sections, fallback: TestConstants.version) == TestConstants.mappedVersion, TestConstants.checkMappedRelease)
        let component = try ReadmeParser.validatedSections(TestConstants.componentReadme)
        check(ReadmeParser.release(component, fallback: ControlConstants.empty) == TestConstants.componentRelease,
              TestConstants.checkComponentRelease)
        let ignoredDeclaration = try ReadmeParser.validatedSections(TestConstants.ignoredDeclaration)
        check(ReadmeParser.usesDatedHistory(component) && !ReadmeParser.usesDatedHistory(sections)
            && !ReadmeParser.usesDatedHistory(ignoredDeclaration), TestConstants.checkDatedHistory)
        for invalid in TestConstants.invalidMappings {
            checkThrows(TestConstants.checkMappingFailure) { _ = try ReadmeParser.validatedSections(invalid) }
        }
        check(ReadmeParser.architecture(try ReadmeParser.validatedSections(TestConstants.mappedWithoutArchitecture)).isEmpty,
              TestConstants.checkMapping)
        let repository = root.appendingPathComponent(TestConstants.secondRepository)
        let project = repository.appendingPathComponent(TestConstants.project)
        try FileManager.default.createDirectory(at: project, withIntermediateDirectories: true)
        let rootReadme = repository.appendingPathComponent(ControlConstants.readme)
        let projectReadme = project.appendingPathComponent(ControlConstants.readme)
        try TestConstants.mappedRoot.write(to: rootReadme, atomically: true, encoding: .utf8)
        try TestConstants.mappedReadme.write(to: projectReadme, atomically: true, encoding: .utf8)
        let snapshot = try RepositoryReader.load(repository)
        check(snapshot.projects.count == 1 && snapshot.overview.first?.text == TestConstants.repositoryOverview
            && snapshot.history.first?.detail == TestConstants.history, TestConstants.checkMappedRoot)
        try TestConstants.mappedRoot.replacingOccurrences(of: TestConstants.mappedHistoryMarker,
            with: TestConstants.registerChildTable + TestConstants.mappedHistoryMarker)
            .write(to: rootReadme, atomically: true, encoding: .utf8)
        check(try RepositoryReader.load(repository).projects.count == 1, TestConstants.checkRegisterChildren)
        let attributes = try FileManager.default.attributesOfItem(atPath: projectReadme.path)
        try TestConstants.mappedReadme.replacingOccurrences(of: TestConstants.digestBefore, with: TestConstants.digestAfter)
            .write(to: projectReadme, atomically: false, encoding: .utf8)
        guard let modified = attributes[.modificationDate] as? Date else { fatalError(TestConstants.checkDigest) }
        try FileManager.default.setAttributes([.modificationDate: modified], ofItemAtPath: projectReadme.path)
        check(RepositoryReader.fingerprint(snapshot) != snapshot.fingerprint, TestConstants.checkDigest)
        try TestConstants.mappedRoot.replacingOccurrences(of: TestConstants.mappedProjectRow, with: ControlConstants.empty)
            .write(to: rootReadme, atomically: true, encoding: .utf8)
        let unregistered = try RepositoryReader.load(repository).projects
        check(unregistered.map(\.name) == [TestConstants.project] && unregistered[0].isRegistered == false
            && unregistered[0].classification == ProjectClassification(), TestConstants.checkEmptyRegister)
        try TestConstants.mappedRoot.replacingOccurrences(of: TestConstants.registerHeader, with: ControlConstants.empty)
            .write(to: rootReadme, atomically: true, encoding: .utf8)
        checkThrows(TestConstants.checkRegisterHeader) { _ = try RepositoryReader.load(repository) }
    }

    /// Lists unregistered top-level folders after the register and notices new ones on the next check.
    /// - Parameter root: Disposable fixture parent; the linked folder's target sits outside the repository.
    /// - Returns: Nothing; fails when a folder is missed, misordered, or listed when it should be skipped.
    private static func discoveryChecks(_ root: URL) throws {
        let repository = root.appendingPathComponent(TestConstants.discoveryDirectory)
        let outsideProject = root.appendingPathComponent(TestConstants.discoveryDirectory + TestConstants.external)
        let names = [TestConstants.project, TestConstants.laterFolder, TestConstants.earlierFolder, TestConstants.hiddenFolder]
        for folder in names.map(repository.appendingPathComponent) + [outsideProject] {
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            try TestConstants.mappedReadme.write(to: folder.appendingPathComponent(ControlConstants.readme),
                atomically: true, encoding: .utf8)
        }
        let readmeless = repository.appendingPathComponent(TestConstants.readmelessFolder)
        try FileManager.default.createDirectory(at: readmeless, withIntermediateDirectories: true)
        try FileManager.default.createSymbolicLink(at: repository.appendingPathComponent(TestConstants.linkedFolder),
            withDestinationURL: outsideProject)
        try TestConstants.mappedRoot.write(to: repository.appendingPathComponent(ControlConstants.readme),
            atomically: true, encoding: .utf8)
        let snapshot = try RepositoryReader.load(repository)
        check(snapshot.projects.map(\.name) == [TestConstants.project, TestConstants.earlierFolder, TestConstants.laterFolder]
            && snapshot.projects.map(\.isRegistered) == [true, false, false], TestConstants.checkDiscovery)
        let found = snapshot.projects[1]
        check(found.classification == ProjectClassification() && found.overview.first?.text == TestConstants.introduction
            && found.version == TestConstants.mappedVersion && !found.history.isEmpty && !found.workflows.isEmpty
            && snapshot.categories.map(\.name).last == ControlConstants.uncategorized, TestConstants.checkDiscoveryContent)
        check(!snapshot.projects.contains { [TestConstants.hiddenFolder, TestConstants.readmelessFolder,
            TestConstants.linkedFolder].contains($0.name) }, TestConstants.checkDiscoverySkips)
        check(RepositoryReader.fingerprint(snapshot) == snapshot.fingerprint, TestConstants.checkDiscoveryStable)
        let added = repository.appendingPathComponent(TestConstants.addedFolder)
        try FileManager.default.createDirectory(at: added, withIntermediateDirectories: true)
        try TestConstants.mappedReadme.write(to: added.appendingPathComponent(ControlConstants.readme), atomically: true, encoding: .utf8)
        let withAdded = try RepositoryReader.load(repository)
        check(RepositoryReader.fingerprint(snapshot) != snapshot.fingerprint
            && withAdded.projects.map(\.name).contains(TestConstants.addedFolder), TestConstants.checkDiscoveryAdded)
        try TestConstants.mappedReadme.write(to: readmeless.appendingPathComponent(ControlConstants.readme), atomically: true, encoding: .utf8)
        check(RepositoryReader.fingerprint(withAdded) != withAdded.fingerprint, TestConstants.checkDiscoveryReadme)
    }

    /// Covers valid Markdown edge cases that previously exposed or truncated content.
    /// - Returns: Nothing; terminates if a parser regression is detected.
    private static func parserChecks() {
        check(!ReadmeParser.sections(TestConstants.misleadingFence).flatMap(\.lines).joined().contains(TestConstants.forbidden), TestConstants.checkFenceSuffix)
        check(ReadmeParser.table(TestConstants.pipeRows).first?.last == TestConstants.pipeValue, TestConstants.checkPipes)
        let flows = ReadmeParser.workflows(ReadmeParser.sections(TestConstants.colonFlows))
        check(flows.first?.steps == [TestConstants.urlStep, TestConstants.resultStep], TestConstants.checkColons)
        check(flows.last?.label == TestConstants.flowLabel, TestConstants.checkLabel)
        let topics = ReadmeParser.sections(TestConstants.topicReadme)
        let overview = ReadmeParser.overview(topics, fallback: ControlConstants.noIntroduction)
        check(overview.first?.text == TestConstants.overviewText && overview.contains { $0.kind == .bullet && $0.text == TestConstants.overviewBullet }, TestConstants.checkOverview)
        check(!overview.contains { $0.text == TestConstants.architecture || $0.text == ControlConstants.workflow }, TestConstants.checkOverviewOwnership)
        check(ReadmeParser.overview(ReadmeParser.sections(TestConstants.projectReadme), fallback: ControlConstants.noIntroduction).first?.text == TestConstants.introduction, TestConstants.checkOverviewFallback)
        check(TestFixtures.text(ReadmeParser.overview(ReadmeParser.sections(TestConstants.overviewOrder), fallback: ControlConstants.noIntroduction)) == TestConstants.overviewOrderExpected, TestConstants.checkOverviewOrder)
        let architecture = TestFixtures.text(ReadmeParser.architecture(topics))
        check(architecture.contains(TestConstants.architecture) && architecture.contains(TestConstants.modelFact)
            && !architecture.contains(TestConstants.obsoleteArchitecture), TestConstants.checkArchitectureOwnership)
        check(TestFixtures.text(ReadmeParser.models(topics)).contains(TestConstants.modelFact), TestConstants.checkModels)
        let diagram = ReadmeParser.workflows(topics).first
        check(diagram?.nodes.count == 5 && diagram?.nodes[1].layer == diagram?.nodes[2].layer, TestConstants.checkDiagramBranches)
        check(diagram?.edges.contains(WorkflowEdge(source: 1, target: 3)) == true
            && diagram?.edges.contains(WorkflowEdge(source: 2, target: 3)) == true, TestConstants.checkDiagramMerge)
        let textFlows = ReadmeParser.workflows(ReadmeParser.sections(TestConstants.textFlows))
        check(textFlows.count == 2 && textFlows.allSatisfy { $0.edges.count == 1 }, TestConstants.checkDiagramLinear)
        check(WorkflowParser.diagrams(TestConstants.codeLikeDiagram, label: ControlConstants.workflow).isEmpty, TestConstants.checkDiagramCode)
        check(WorkflowParser.diagrams(TestConstants.malformedDiagram, label: ControlConstants.workflow).isEmpty, TestConstants.checkDiagramMalformed)
        check(WorkflowParser.diagrams(TestConstants.incompleteDiagram, label: ControlConstants.workflow).isEmpty
            && WorkflowParser.linear(TestConstants.incompleteRoute, label: ControlConstants.workflow) == nil, TestConstants.checkDiagramIncomplete)
        check(WorkflowParser.diagrams(TestConstants.asciiDiagram, label: ControlConstants.workflow).count == 2, TestConstants.checkAsciiDiagram)
        let titled = ReadmeParser.workflows(ReadmeParser.sections(TestConstants.titledDiagram))
        check(titled.map(\.label) == TestConstants.titledRouteNames, TestConstants.checkDiagramTitles)
        check(titled.first?.nodes.last?.label == TestConstants.proseStage
            && titled.last?.nodes.count == 4 && titled.last?.edges.count == 4, TestConstants.checkDiagramProse)
        check(ReadmeParser.workflows(ReadmeParser.sections(TestConstants.manyRoutes)).count == 10, TestConstants.checkDiagramCount)
        let versioned = ReadmeParser.sections(TestConstants.versionedOverview)
        check(ReadmeParser.overview(versioned, fallback: ControlConstants.noIntroduction).first?.text == TestConstants.overviewText
            && TestFixtures.text(ReadmeParser.architecture(versioned)).contains(TestConstants.architecture)
            && ReadmeParser.workflows(versioned).count == 1 && ReadmeParser.history(versioned).isEmpty, TestConstants.checkVersionedTitle)
    }

    /// Reproduces the reported leading-blank-line table leak and preserves source identifiers.
    /// - Returns: Nothing; terminates if tables become prose or model/path text changes.
    private static func tableChecks() {
        let sections = ReadmeParser.sections(TestConstants.modelTables)
        let models = ReadmeParser.models(sections)
        let tables = models.compactMap(\.table)
        check(tables.count == 2 && tables[0].headers == TestConstants.modelHeaders, TestConstants.checkStructuredTables)
        check(tables[0].rows.count == 2 && tables[1].headers == TestConstants.pathHeaders, TestConstants.checkModelTableRows)
        check(models.filter { $0.kind == .paragraph }.isEmpty, TestConstants.checkTableProseLeak)
        check(TestFixtures.text(ReadmeParser.architecture(sections)).contains(TestConstants.architecture), TestConstants.checkArchitectureOwnership)
        check(tables[1].rows.first?.last == TestConstants.modelPath, TestConstants.checkModelIdentifiers)
        check(ReadmeParser.plain(TestConstants.inlineIdentifiers) == TestConstants.expectedIdentifiers, TestConstants.checkModelIdentifiers)
        check(ReadmeParser.paragraphs(ReadmeParser.sections(TestConstants.adjacentTable)) == TestConstants.adjacentProse, TestConstants.checkAdjacentTable)
        let overview = ReadmeParser.overview(ReadmeParser.sections(TestConstants.overviewOrder), fallback: ControlConstants.noIntroduction)
        check(overview.map(\.kind) == [.paragraph, .table, .bullet, .paragraph], TestConstants.checkOverviewTable)
        let escaped = ReadmeParser.overview(ReadmeParser.sections(TestConstants.escapedTable), fallback: ControlConstants.noIntroduction)
        check(escaped.first?.table?.rows.first?.last == TestConstants.pipeValue, TestConstants.checkPipes)
    }

    /// Preserves complete architecture responsibilities and source dates in history headings.
    /// - Returns: Nothing; terminates if source tables lose components or dates remain in the detail body.
    private static func architectureHistoryChecks() {
        let sections = ReadmeParser.sections(TestConstants.mixedArchitecture)
        let tables = ReadmeParser.architecture(sections).compactMap(\.table)
        check(tables.first?.rows.count == 3 && tables.first?.headers == TestConstants.pathHeaders,
              TestConstants.checkCompleteArchitecture)
        let routes = ReadmeParser.workflows(sections)
        check(routes.count == 2 && routes.first?.steps == TestConstants.mixedSteps, TestConstants.checkMixedArchitecture)
        check(ReadmeParser.models(sections).compactMap(\.table).first?.rows.count == 1, TestConstants.checkModelSecondary)
        let rootHistory = ReadmeParser.history(ReadmeParser.sections(TestConstants.rootReadme))[0]
        check(rootHistory.date == TestConstants.historyDate && rootHistory.heading == TestConstants.datedRootHeading,
              TestConstants.checkHistoryHeading)
        check(rootHistory.detail == TestConstants.rootHistoryDetail, TestConstants.checkHistoryDateBody)
        let releases = ReadmeParser.history(ReadmeParser.sections(TestConstants.datedHistory))
        check(releases[0].heading == TestConstants.datedVersionHeading && releases[0].detail == TestConstants.history,
              TestConstants.checkHistoryHeading)
        check(releases[1].date == nil && releases[1].detail == TestConstants.history, TestConstants.checkUndatedHistory)
        let undated = ReadmeParser.history(ReadmeParser.sections(TestConstants.projectReadme))[0]
        check(undated.date == nil && undated.detail == TestConstants.history, TestConstants.checkUndatedHistory)
    }

    /// Exercises automatic app discovery without launching any fixture or reading user preferences.
    /// - Parameters:
    ///   - repository: Disposable repository.
    ///   - project: Registered project folder.
    ///   - root: Fixture boundary.
    /// - Returns: Nothing; throws on fixture failure and terminates on incorrect discovery behavior.
    private static func applicationChecks(_ repository: URL, project: URL, root: URL) throws {
        let before = try RepositoryReader.load(repository)
        let application = try TestFixtures.application(in: project, name: TestConstants.project)
        let companion = try TestFixtures.application(in: project, name: TestConstants.companion)
        _ = try TestFixtures.application(in: project.appendingPathComponent(TestConstants.nestedBuild), name: TestConstants.project)
        let incomplete = project.appendingPathComponent(TestConstants.incompleteApp + TestConstants.appSuffix)
        try FileManager.default.createDirectory(at: incomplete, withIntermediateDirectories: true)
        let detected = try RepositoryReader.load(repository).projects[0].applications
        check(detected.count == 2 && detected.contains(application) && detected.contains(companion), TestConstants.checkAppDetection)
        check(ApplicationLocator.preferred(detected, project: TestConstants.project, folder: project) == application, TestConstants.checkAppPreference)
        check(ApplicationLocator.preferred([companion], project: TestConstants.project, folder: project) == companion, TestConstants.checkAppSingle)
        check(ApplicationLocator.preferred(detected, project: TestConstants.external, folder: root) == nil, TestConstants.checkAppAmbiguous)
        check(ApplicationLocator.preferred(detected, project: TestConstants.external, folder: project) == application, TestConstants.checkAppFolderMatch)
        check(ApplicationLocator.preferred([], project: TestConstants.project, folder: project) == nil, TestConstants.checkAppFallback)
        check(RepositoryReader.fingerprint(before) != before.fingerprint, TestConstants.checkAppFingerprint)
        let beforeRepair = try RepositoryReader.load(repository)
        _ = try TestFixtures.application(in: project, name: TestConstants.incompleteApp)
        check(RepositoryReader.fingerprint(beforeRepair) != beforeRepair.fingerprint, TestConstants.checkAppFingerprint)
        let outside = try TestFixtures.application(in: root, name: TestConstants.external)
        let link = project.appendingPathComponent(TestConstants.linkedApp)
        try FileManager.default.createSymbolicLink(at: link, withDestinationURL: outside)
        check(!ApplicationLocator.candidates(in: project, within: repository).contains(outside), TestConstants.checkAppEscape)
        let info = incomplete.appendingPathComponent(ControlConstants.appContents).appendingPathComponent(ControlConstants.appInfo)
        try FileManager.default.removeItem(at: info)
        try FileManager.default.createSymbolicLink(at: info, withDestinationURL: outside.appendingPathComponent(ControlConstants.appContents).appendingPathComponent(ControlConstants.appInfo))
        check(!ApplicationLocator.isApplication(incomplete), TestConstants.checkAppEscape)
        try FileManager.default.removeItem(at: application)
        check(!ApplicationLocator.isApplication(application), TestConstants.checkAppMissing)
        try applicationRefreshChecks(repository, application: companion)
    }

    /// Covers app changes that do not modify the project folder or restart this process.
    /// - Parameters:
    ///   - repository: Disposable register.
    ///   - application: Valid disposable companion bundle.
    /// - Returns: Nothing; throws on fixture failure and terminates if fresh metadata is ignored.
    private static func applicationRefreshChecks(_ repository: URL, application: URL) throws {
        let contents = application.appendingPathComponent(ControlConstants.appContents)
        let executableFolder = contents.appendingPathComponent(ControlConstants.appExecutableFolder)
        let executable = executableFolder.appendingPathComponent(TestConstants.executableName)
        let before = try RepositoryReader.load(repository)
        try FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: executable.path)
        check(!ApplicationLocator.isApplication(application)
            && RepositoryReader.fingerprint(before) != before.fingerprint, TestConstants.checkAppExecutableRefresh)
        let disabled = try RepositoryReader.load(repository)
        try FileManager.default.setAttributes([.posixPermissions: 0o700], ofItemAtPath: executable.path)
        check(RepositoryReader.fingerprint(disabled) != disabled.fingerprint
            && ApplicationLocator.isApplication(application), TestConstants.checkAppExecutableRefresh)
        let info = contents.appendingPathComponent(ControlConstants.appInfo)
        let metadata = [ControlConstants.bundleTypeKey: ControlConstants.bundleApplicationType,
            ControlConstants.bundleExecutableKey: TestConstants.replacementExecutable]
        try PropertyListSerialization.data(fromPropertyList: metadata, format: .binary, options: 0).write(to: info)
        check(!ApplicationLocator.isApplication(application), TestConstants.checkAppMetadataReload)
        let replacement = executableFolder.appendingPathComponent(TestConstants.replacementExecutable)
        try FileManager.default.createDirectory(at: replacement, withIntermediateDirectories: true)
        check(!ApplicationLocator.isApplication(application), TestConstants.checkAppExecutableFile)
        try FileManager.default.removeItem(at: replacement)
        try FileManager.default.moveItem(at: executable, to: replacement)
        check(ApplicationLocator.isApplication(application), TestConstants.checkAppMetadataReload)
        try TestConstants.corrupt.write(to: info, atomically: true, encoding: .utf8)
        check(!ApplicationLocator.isApplication(application), TestConstants.checkAppMetadataReload)
        try Data(repeating: 0, count: ControlConstants.maxReadmeBytes + 1).write(to: info)
        check(!ApplicationLocator.isApplication(application), TestConstants.checkAppMetadataBound)
    }

    /// Checks canonical project identities, alias retargeting, and root README boundaries.
    /// - Parameters:
    ///   - repository: Disposable repository.
    ///   - project: Its real project folder.
    ///   - outside: External fixture file.
    /// - Returns: Nothing; throws on fixture setup failure.
    private static func aliasChecks(_ repository: URL, project: URL, outside: URL) throws {
        let alias = repository.appendingPathComponent(TestConstants.alias)
        let rootReadme = repository.appendingPathComponent(ControlConstants.readme)
        try FileManager.default.createSymbolicLink(at: alias, withDestinationURL: project)
        try TestConstants.aliasRoot.write(to: rootReadme, atomically: true, encoding: .utf8)
        let snapshot = try RepositoryReader.load(repository)
        check(snapshot.projects.count == 1 && snapshot.projects[0].id == project.resolvingSymlinksInPath().path, TestConstants.checkAlias)
        let aliasRecord = ProjectRecord(id: project.path, name: TestConstants.alias, folder: alias,
            readme: alias.appendingPathComponent(ControlConstants.readme), introduction: ControlConstants.empty,
            version: nil, architecture: [], workflows: [], history: [], folderAvailable: true, readmeAvailable: false)
        let aliasSnapshot = RepositorySnapshot(root: repository, projects: [aliasRecord], history: [], readAt: Date(), fingerprint: [])
        let before = RepositoryReader.fingerprint(aliasSnapshot)
        let resolvedAlias = ProjectRecord(id: project.resolvingSymlinksInPath().standardizedFileURL.path,
            name: TestConstants.alias, folder: alias, readme: aliasRecord.readme, introduction: ControlConstants.empty,
            version: nil, architecture: [], workflows: [], history: [], folderAvailable: true, readmeAvailable: false)
        check(resolvedAlias.hasCurrentIdentity, TestConstants.checkIconIdentity)
        let outsideFolder = outside.deletingLastPathComponent().appendingPathComponent("ExternalApps")
        let outsideApplication = try TestFixtures.application(in: outsideFolder, name: "Unexpected")
        try FileManager.default.removeItem(at: alias)
        try FileManager.default.createSymbolicLink(at: alias, withDestinationURL: outsideFolder)
        check(ApplicationLocator.candidates(in: alias, within: repository).isEmpty
            && !ApplicationLocator.isCurrentCandidate(outsideApplication, for: aliasRecord),
            "retargeted project aliases cannot scan or validate external automatic apps")
        check(!resolvedAlias.hasCurrentIdentity, TestConstants.checkIconRetarget)
        try FileManager.default.removeItem(at: alias)
        try FileManager.default.createSymbolicLink(at: alias, withDestinationURL: outside)
        check(RepositoryReader.fingerprint(aliasSnapshot) != before, TestConstants.checkAliasChange)
        try FileManager.default.removeItem(at: rootReadme)
        try FileManager.default.createSymbolicLink(at: rootReadme, withDestinationURL: outside)
        check(!RepositoryReader.contains(rootReadme, in: repository), TestConstants.checkRootSymlink)
    }

    /// Exercises first-use, round-trip, and corruption behavior without touching user data.
    /// - Parameter root: Disposable directory created by this test process.
    /// - Returns: Nothing; throws on unexpected filesystem failures.
    private static func storageChecks(_ root: URL) throws {
        let storage = WorkspaceStorage(file: root.appendingPathComponent(ControlConstants.stateFile))
        check(try storage.load().notes.isEmpty, TestConstants.checkEmpty)
        var state = WorkspaceState()
        let note = WorkNote(text: TestConstants.title + ControlConstants.newline + TestConstants.detail)
        state.notes[TestConstants.project] = [note]
        try storage.save(state)
        check(try storage.load().notes[TestConstants.project] == [note], TestConstants.checkNotes)
        try TestConstants.corrupt.write(to: storage.file, atomically: true, encoding: .utf8)
        checkThrows(TestConstants.checkCorrupt) { _ = try storage.load() }
    }

    /// Wraps bare timestamps as Git records with no mapped project paths.
    /// - Parameter timestamps: Timestamp fields exactly as Git would report them.
    /// - Returns: One repository-level record per timestamp, in source order.
    private static func timestampRecords(_ timestamps: [String]) -> [GitCommitMetadata] {
        timestamps.map { GitCommitMetadata(timestamp: $0, projectIDs: []) }
    }

    /// Records a single deterministic assertion.
    /// - Parameters:
    ///   - condition: Expected truth value.
    ///   - label: Failure explanation.
    /// - Returns: Nothing; terminates unsuccessfully on failure.
    private static func check(_ condition: Bool, _ label: String) {
        guard condition else { fatalError(TestConstants.failed + label) }
        count += 1
    }

    /// Asserts that an operation rejects invalid input.
    /// - Parameters:
    ///   - label: Failure explanation.
    ///   - action: Expected throwing operation.
    /// - Returns: Nothing; terminates if no error is raised.
    private static func checkThrows(_ label: String, action: () throws -> Void) {
        do { try action(); check(false, label) }
        catch { count += 1 }
    }
}
