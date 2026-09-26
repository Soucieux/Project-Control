import SwiftUI

/// The repository parent owns its README overview, history, commit activity, source action, and read timestamp.
internal struct RepositoryScreen: View {
    @ObservedObject internal var store: ControlStore
    internal let snapshot: RepositorySnapshot
    @State private var tab = RepositoryTab.overview
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    internal var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack {
                InstrumentLabel(title: ControlConstants.repository)
                Spacer()
                if store.loading { ProgressView().controlSize(.small) }
                Text(ControlConstants.lastRead + ControlConstants.space + snapshot.readAt.formatted(date: .omitted, time: .standard))
                    .font(.caption.monospaced()).foregroundStyle(ControlTheme.muted)
            }
            GlassCard {
                HStack(spacing: 18) {
                    Image(systemName: ControlConstants.folderIcon).font(.system(size: 36, weight: .light))
                        .foregroundStyle(ControlTheme.mint).accessibilityHidden(true)
                    Text(snapshot.root.lastPathComponent).font(.system(size: 38, weight: .light))
                        .tracking(-1).fixedSize(horizontal: false, vertical: true)
                }
            }
            if let warning = store.syncFailure {
                Text(ControlConstants.staleContent + ControlConstants.space + warning)
                    .font(.callout).foregroundStyle(ControlTheme.amber)
            }
            TabStrip(tabs: RepositoryTab.allCases, label: \.label, selection: $tab)
            Group {
                switch tab {
                case .overview: ReadmeContent(blocks: snapshot.overview, empty: ControlConstants.noRepositoryOverview)
                case .history: HistoryList(entries: snapshot.history)
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
