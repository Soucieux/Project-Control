import SwiftUI

/// The repository parent's screen: its name and project count on the sky, then its README overview, history,
/// and commit activity.
internal struct RepositoryScreen: View {
    @ObservedObject internal var store: ControlStore
    internal let snapshot: RepositorySnapshot
    @State private var tab = RepositoryTab.overview
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    internal var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // The title sits on the sky itself, centered above the column, with the project count beneath.
            VStack(spacing: 8) {
                Text(snapshot.root.lastPathComponent).font(.system(size: 40, weight: .light)).tracking(-1)
                    .fixedSize(horizontal: false, vertical: true).accessibilityAddTraits(.isHeader)
                Text(snapshot.projectCountLabel + ControlConstants.joined + ControlConstants.repositorySummary)
                    .font(.callout).foregroundStyle(ControlTheme.muted)
            }.multilineTextAlignment(.center).frame(maxWidth: .infinity).padding(.vertical, 12)
            if let warning = store.syncFailure {
                Text(ControlConstants.staleContent + ControlConstants.space + warning)
                    .font(.callout).foregroundStyle(ControlTheme.amber)
            }
            VStack(alignment: .leading, spacing: ControlTheme.tabContentGap) {
                TabStrip(tabs: RepositoryTab.allCases, label: \.label, selection: $tab)
                Group {
                    switch tab {
                    case .overview: ReadmeContent(blocks: snapshot.overview, empty: ControlConstants.noRepositoryOverview)
                    case .history: HistoryList(entries: snapshot.changelog.isEmpty ? snapshot.history : snapshot.changelog,
                        strip: snapshot.strip)
                    case .activity:
                        TimelineView(.everyMinute) { context in
                            CommitActivityView(activity: snapshot.commitActivity,
                                projects: snapshot.projects, now: context.date)
                        }
                    }
                }.transition(.opacity).animation(reduceMotion ? nil : ControlTheme.motion, value: tab)
            }
        }
    }
}

extension RepositorySnapshot {
    /// The number of listed projects in words, as the repository title and the rail's count help show it.
    internal var projectCountLabel: String {
        String(format: projects.count == 1 ? ControlConstants.singleProjectCountFormat
            : ControlConstants.projectCountFormat, projects.count)
    }
}
