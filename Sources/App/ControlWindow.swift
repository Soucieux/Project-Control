import AppKit
import SwiftUI

/// The perimeter-led command surface: register, selected project, repository history.
internal struct ControlWindow: View {
    @ObservedObject internal var store: ControlStore
    @State private var showRepositoryHistory = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    internal var body: some View {
        VStack(spacing: 0) {
            masthead
            if let message = store.error {
                HStack(alignment: .top) {
                    Image(systemName: ControlConstants.warningIcon)
                    Text(message).textSelection(.enabled)
                    Spacer()
                    Button(ControlConstants.dismiss) { store.error = nil }
                }.font(.callout).foregroundStyle(ControlTheme.amber).padding(14).background(ControlTheme.surface)
            }
            if let snapshot = store.snapshot {
                HStack(spacing: 0) {
                    register(snapshot)
                    Rectangle().fill(ControlTheme.line).frame(width: 1)
                    if let project = store.selectedProject {
                        ScrollView {
                            ProjectScreen(store: store, project: project).padding(28)
                                .frame(maxWidth: 1050).frame(maxWidth: .infinity)
                        }.id(project.id)
                    } else { Spacer() }
                }
                repositoryFooter(snapshot)
            } else {
                VStack(alignment: .leading, spacing: 24) {
                    Image(systemName: ControlConstants.diamondIcon).font(.system(size: 48, weight: .ultraLight))
                    Text(ControlConstants.noRepository).font(.system(size: 38, weight: .light))
                    Text(ControlConstants.connectExplanation).font(.body).foregroundStyle(ControlTheme.muted).lineSpacing(5)
                    Button(ControlConstants.chooseRepository) { store.chooseRepository() }
                        .buttonStyle(.borderedProminent).controlSize(.large).foregroundStyle(ControlTheme.background)
                    if store.loading { ProgressView().controlSize(.small) }
                }.frame(maxWidth: 550, alignment: .leading).padding(50).frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .foregroundStyle(ControlTheme.ink).tint(ControlTheme.signal)
        .background(ControlTheme.background)
        .animation(reduceMotion ? nil : ControlTheme.motion, value: showRepositoryHistory)
    }

    private var masthead: some View {
        HStack(spacing: 12) {
            Image(nsImage: NSApplication.shared.applicationIconImage).resizable().interpolation(.high)
                .scaledToFit().frame(width: 32, height: 32)
                .accessibilityHidden(true)
            Text(ControlConstants.appName.uppercased()).font(.system(size: 13, weight: .medium)).tracking(3)
            Spacer()
            if let root = store.snapshot?.root {
                Text(root.lastPathComponent).font(.callout).foregroundStyle(ControlTheme.muted)
            }
            Menu {
                Button(ControlConstants.changeRepository) { store.chooseRepository() }
                Button(ControlConstants.refresh) {
                    if let root = store.snapshot?.root { Task { await store.reload(root) } }
                }.disabled(store.snapshot == nil || store.loading)
            } label: { Image(systemName: ControlConstants.menuIcon) }
                .menuStyle(.borderlessButton).frame(width: 24).help(ControlConstants.changeRepository)
        }
        .padding(.leading, 82).padding(.trailing, 24).frame(height: 68)
        .background(ControlTheme.rail)
        .overlay(alignment: .bottom) { Rectangle().fill(ControlTheme.line).frame(height: 1) }
    }

    /// Builds numbered, full-row project navigation without inventing status scores.
    /// - Parameter snapshot: Current repository snapshot.
    /// - Returns: A fixed-width, independently scrollable project register.
    private func register(_ snapshot: RepositorySnapshot) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack { InstrumentLabel(title: ControlConstants.register); Spacer(); Text(snapshot.projects.count.formatted()).font(.caption.monospaced()) }
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(Array(snapshot.projects.enumerated()), id: \.element.id) { index, project in
                        Button {
                            store.selection = project.id
                        } label: {
                            HStack(alignment: .top, spacing: 10) {
                                Text(String(format: ControlConstants.ordinalFormat, index + 1)).font(.caption.monospaced()).padding(.top, 2)
                                VStack(alignment: .leading, spacing: 7) {
                                    Text(project.name).font(.system(size: 14, weight: .medium)).multilineTextAlignment(.leading)
                                    let notes = store.notes(for: project.id)
                                    Text(notes.isEmpty ? ControlConstants.noProgress : String(format: ControlConstants.noteCountFormat, notes.filter { $0.status == .done }.count, notes.count) + ControlConstants.space + ControlConstants.completedNotes)
                                        .font(.system(size: 11)).foregroundStyle(ControlTheme.muted)
                                }
                                Spacer(minLength: 0)
                            }.padding(.vertical, 18).padding(.horizontal, 10).frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(Rectangle())
                                .background(store.selection == project.id ? ControlTheme.signal.opacity(0.12) : .clear)
                                .overlay(alignment: .leading) {
                                    if store.selection == project.id { Rectangle().fill(ControlTheme.signal).frame(width: 2) }
                                }
                        }.buttonStyle(.plain)
                            .accessibilityAddTraits(store.selection == project.id ? .isSelected : [])
                        Rectangle().fill(ControlTheme.line).frame(height: 1)
                    }
                }
            }
            Spacer(minLength: 0)
            InstrumentLabel(title: ControlConstants.localOnly).font(.caption)
            Text(ControlConstants.checkCadence).font(.caption).foregroundStyle(ControlTheme.muted).fixedSize(horizontal: false, vertical: true)
        }.padding(18).frame(width: 236).background(ControlTheme.rail.opacity(0.65))
    }

    /// Separates repository-wide changes from the selected project's own release history.
    /// - Parameter snapshot: Current repository snapshot.
    /// - Returns: A collapsible, height-bounded history panel and source timestamp.
    private func repositoryFooter(_ snapshot: RepositorySnapshot) -> some View {
        VStack(spacing: 10) {
            HStack {
                Button {
                    showRepositoryHistory.toggle()
                } label: {
                    Label(ControlConstants.repositoryHistory, systemImage: ControlConstants.diamondIcon)
                }.buttonStyle(.plain)
                Spacer()
                Text(ControlConstants.lastRead + ControlConstants.space + snapshot.readAt.formatted(date: .omitted, time: .standard))
                    .font(.caption.monospaced()).foregroundStyle(ControlTheme.muted)
                Button(ControlConstants.read) { store.open(snapshot.root.appendingPathComponent(ControlConstants.readme)) }
                    .font(.caption)
            }
            if showRepositoryHistory {
                ScrollView { HistoryList(entries: snapshot.history) }.frame(height: 210)
            }
        }.padding(.horizontal, 24).padding(.vertical, 15).background(ControlTheme.rail)
            .overlay(alignment: .top) { Rectangle().fill(ControlTheme.line).frame(height: 1) }
    }
}

/// Readable, expandable summaries rather than raw Markdown or source files.
internal struct HistoryList: View {
    internal let entries: [HistoryEntry]
    internal var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            if entries.isEmpty { Text(ControlConstants.noHistory).foregroundStyle(ControlTheme.muted) }
            ForEach(entries) { entry in
                DisclosureGroup {
                    Text(entry.detail).font(.callout).lineSpacing(4).textSelection(.enabled)
                        .foregroundStyle(ControlTheme.muted).frame(maxWidth: .infinity, alignment: .leading).padding(.vertical, 8)
                } label: { Text(entry.title).font(.callout) }
                Rectangle().fill(ControlTheme.line).frame(height: 1)
            }
        }.padding(.vertical, 10)
    }
}
