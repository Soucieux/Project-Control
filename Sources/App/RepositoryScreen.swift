import SwiftUI

/// The repository parent owns its README overview, history, source action, and read timestamp.
internal struct RepositoryScreen: View {
    @ObservedObject internal var store: ControlStore
    internal let snapshot: RepositorySnapshot
    @State private var showHistory = false
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
            Button { store.open(snapshot.root.appendingPathComponent(ControlConstants.readme)) } label: {
                Label(ControlConstants.read, systemImage: ControlConstants.readIcon)
            }.buttonStyle(.bordered).controlSize(.large)
            if let warning = store.syncFailure {
                Text(ControlConstants.staleContent + ControlConstants.space + warning)
                    .font(.callout).foregroundStyle(ControlTheme.amber)
            }
            HStack(spacing: 20) {
                ForEach([false, true], id: \.self) { history in
                    Button { showHistory = history } label: {
                        Text(history ? ControlConstants.repositoryHistory : ControlConstants.overview)
                            .font(.system(size: 13, weight: showHistory == history ? .semibold : .regular))
                            .foregroundStyle(showHistory == history ? ControlTheme.ink : ControlTheme.muted)
                            .padding(.vertical, 12).contentShape(Rectangle())
                            .overlay(alignment: .bottom) {
                                if showHistory == history { Rectangle().fill(ControlTheme.signal).frame(height: 2) }
                            }
                    }.buttonStyle(.plain).accessibilityAddTraits(showHistory == history ? .isSelected : [])
                }
                Spacer(minLength: 0)
            }.padding(.horizontal, 14)
                .background(Color.white.opacity(0.30), in: RoundedRectangle(cornerRadius: 13, style: .continuous))
            Group {
                if showHistory { HistoryList(entries: snapshot.history) }
                else { ReadmeContent(blocks: snapshot.overview, empty: ControlConstants.noRepositoryOverview) }
            }.transition(.opacity).animation(reduceMotion ? nil : ControlTheme.motion, value: showHistory)
        }
    }
}
