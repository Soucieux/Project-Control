import AppKit
import SwiftUI

/// The perimeter-led command surface: register, selected project, repository history.
internal struct ControlWindow: View {
    @ObservedObject internal var store: ControlStore
    @State private var collapsedCategories: Set<String> = []

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
                    } else {
                        ScrollView {
                            RepositoryScreen(store: store, snapshot: snapshot).padding(28)
                                .frame(maxWidth: 1050).frame(maxWidth: .infinity)
                        }.id(snapshot.root.path)
                    }
                }
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
        .onChange(of: store.snapshot?.root) { _, _ in collapsedCategories.removeAll() }
        .onChange(of: store.selectedProject?.classification.category) { _, category in
            if let category { collapsedCategories.remove(category) }
        }
    }

    private var masthead: some View {
        HStack(spacing: 12) {
            Image(nsImage: NSApplication.shared.applicationIconImage).resizable().interpolation(.high)
                .scaledToFit().frame(width: 36, height: 36)
                .accessibilityHidden(true)
            Text(ControlConstants.appName).font(.system(size: 18, weight: .semibold))
                .lineLimit(1).fixedSize().layoutPriority(1)
            Spacer(minLength: 24)
            if let root = store.snapshot?.root {
                Text(root.lastPathComponent).font(.callout).foregroundStyle(ControlTheme.muted)
                    .lineLimit(1).truncationMode(.middle).help(root.lastPathComponent)
            }
            Menu {
                Button(ControlConstants.changeRepository) { store.chooseRepository() }
                Button(ControlConstants.refresh) {
                    if let root = store.snapshot?.root { Task { await store.reload(root) } }
                }.disabled(store.snapshot == nil || store.loading)
            } label: {
                Image(systemName: ControlConstants.menuIcon).font(.system(size: 17, weight: .medium))
                    .frame(width: 36, height: 36).contentShape(Rectangle())
            }
                .menuStyle(.borderlessButton).menuIndicator(.hidden).fixedSize()
                .help(ControlConstants.repositoryActions).accessibilityLabel(ControlConstants.repositoryActions)
        }
        .padding(.horizontal, 24).frame(height: 60)
        .background(ControlTheme.rail)
        .overlay(alignment: .bottom) { Rectangle().fill(ControlTheme.line).frame(height: 1) }
    }

    /// Places a selectable repository parent above source-ordered, collapsible project categories.
    /// - Parameter snapshot: Current repository snapshot.
    /// - Returns: A fixed-width, independently scrollable project register.
    private func register(_ snapshot: RepositorySnapshot) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack { InstrumentLabel(title: ControlConstants.register); Spacer(); Text(snapshot.projects.count.formatted()).font(.caption.monospaced()) }
            ScrollView {
                VStack(spacing: 0) {
                    Button { store.selection = snapshot.root.path } label: {
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: ControlConstants.folderIcon).font(.system(size: 21, weight: .light))
                                .frame(width: 24, height: 24).accessibilityHidden(true)
                            VStack(alignment: .leading, spacing: 7) {
                                Text(snapshot.root.lastPathComponent).font(.system(size: 14, weight: .medium)).multilineTextAlignment(.leading)
                                Text(ControlConstants.repositorySummary).font(.system(size: 11)).foregroundStyle(ControlTheme.muted)
                            }
                            Spacer(minLength: 0)
                        }.padding(.vertical, 18).padding(.horizontal, 10).frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(Rectangle())
                            .background(store.selection == snapshot.root.path ? ControlTheme.signal.opacity(0.12) : .clear)
                            .overlay(alignment: .leading) {
                                if store.selection == snapshot.root.path { Rectangle().fill(ControlTheme.signal).frame(width: 2) }
                            }
                    }.buttonStyle(.plain).accessibilityAddTraits(store.selection == snapshot.root.path ? .isSelected : [])
                    Rectangle().fill(ControlTheme.line).frame(height: 1)
                    ForEach(snapshot.categories) { category in
                        categoryHeader(category)
                        if !collapsedCategories.contains(category.name) {
                            ForEach(category.projects) { project in projectRow(project) }
                        }
                    }
                }
            }
            Spacer(minLength: 0)
            InstrumentLabel(title: ControlConstants.localOnly).font(.caption)
            Text(ControlConstants.checkCadence).font(.caption).foregroundStyle(ControlTheme.muted).fixedSize(horizontal: false, vertical: true)
        }.padding(18).frame(width: 260).background(ControlTheme.rail.opacity(0.65))
    }

    /// Toggles one category without changing the selected project or its work notes.
    /// - Parameter category: README label and its current project membership.
    /// - Returns: A full-width keyboard-focusable disclosure button with a project count.
    private func categoryHeader(_ category: ProjectCategory) -> some View {
        let collapsed = collapsedCategories.contains(category.name)
        return Button {
            if collapsed { collapsedCategories.remove(category.name) }
            else { collapsedCategories.insert(category.name) }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: collapsed ? ControlConstants.collapsedIcon : ControlConstants.expandedIcon)
                    .font(.system(size: 9, weight: .semibold)).frame(width: 10).accessibilityHidden(true)
                Text(category.name).font(.system(size: 12, weight: .semibold))
                    .multilineTextAlignment(.leading).fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 4)
                Text(category.projects.count.formatted()).font(.caption.monospaced()).foregroundStyle(ControlTheme.muted)
            }.padding(.horizontal, 10).padding(.vertical, 14).frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
        }.buttonStyle(.plain).accessibilityValue(collapsed ? ControlConstants.collapsed : ControlConstants.expanded)
    }

    /// Shows documented scope and technology tags without inferring capabilities or absence labels.
    /// - Parameter project: Registered project with root-owned classification metadata.
    /// - Returns: A full-row selection button preserving the project's icon and note progress.
    private func projectRow(_ project: ProjectRecord) -> some View {
        Button { store.selection = project.id } label: {
            HStack(alignment: .top, spacing: 10) {
                ProjectIcon(project: project, size: 24)
                VStack(alignment: .leading, spacing: 7) {
                    Text(project.name).font(.system(size: 14, weight: .medium))
                        .multilineTextAlignment(.leading).fixedSize(horizontal: false, vertical: true)
                    if let scope = project.classification.technicalScope {
                        Text(scope).font(.system(size: 11)).foregroundStyle(ControlTheme.muted)
                            .multilineTextAlignment(.leading).fixedSize(horizontal: false, vertical: true)
                            .help(ControlConstants.technicalScope + ControlConstants.colon + ControlConstants.space + scope)
                    }
                    if !project.classification.technologies.isEmpty {
                        TechnologyTagLayout {
                            ForEach(project.classification.technologies, id: \.self) { technology in
                                ClassificationBadge(title: ControlConstants.technology, value: technology)
                            }
                        }
                    }
                    let notes = store.notes(for: project.id)
                    Text(notes.isEmpty ? ControlConstants.noProgress : String(format: ControlConstants.noteCountFormat,
                        notes.filter { $0.status == .done }.count, notes.count) + ControlConstants.space + ControlConstants.completedNotes)
                        .font(.system(size: 11)).foregroundStyle(ControlTheme.muted)
                }
                Spacer(minLength: 0)
            }.padding(.vertical, 12).padding(.horizontal, 10).padding(.leading, 14)
                .frame(maxWidth: .infinity, alignment: .leading).contentShape(Rectangle())
                .background(store.selection == project.id ? ControlTheme.signal.opacity(0.12) : .clear)
                .overlay(alignment: .leading) {
                    if store.selection == project.id { Rectangle().fill(ControlTheme.signal).frame(width: 2) }
                }
        }.buttonStyle(.plain).accessibilityAddTraits(store.selection == project.id ? .isSelected : [])
    }
}

/// A wrapping informational badge; its appearance does not imply a clickable action or health state.
internal struct ClassificationBadge: View {
    internal let title: String
    internal let value: String

    internal var body: some View {
        Text(value).font(.system(size: 10, weight: .medium)).foregroundStyle(ControlTheme.muted)
            .multilineTextAlignment(.leading).fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 6).padding(.vertical, 3)
            .background(ControlTheme.signal.opacity(0.04), in: RoundedRectangle(cornerRadius: 4))
            .overlay { RoundedRectangle(cornerRadius: 4).stroke(ControlTheme.line, lineWidth: 0.5) }
            .help(title + ControlConstants.colon + ControlConstants.space + value)
            .accessibilityElement(children: .ignore).accessibilityLabel(title).accessibilityValue(value)
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
                } label: { Text(entry.heading).font(.callout) }
                Rectangle().fill(ControlTheme.line).frame(height: 1)
            }
        }.padding(.vertical, 10)
    }
}
