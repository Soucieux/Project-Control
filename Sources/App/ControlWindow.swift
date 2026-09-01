import AppKit
import SwiftUI

/// The layered command surface: animated navigation rail, glass content, and privacy artwork.
internal struct ControlWindow: View {
    @ObservedObject internal var store: ControlStore
    @State private var collapsedCategories: Set<String> = []
    @State private var sidebarExpanded = true
    @State private var displayLocked = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    internal var body: some View {
        ZStack {
            Color.clear
            WindowTransparencyConfigurator().frame(width: 0, height: 0).accessibilityHidden(true)
            if displayLocked {
                LockedArtwork { setLocked(false) }
                    .ignoresSafeArea()
                    .transition(.opacity.combined(with: .scale(scale: 0.985)))
            } else {
                applicationShell
                    .ignoresSafeArea()
                    .transition(.opacity.combined(with: .scale(scale: 0.99)))
            }
        }
        .foregroundStyle(ControlTheme.ink).tint(ControlTheme.mint)
        .animation(reduceMotion ? nil : ControlTheme.motion, value: displayLocked)
        .onChange(of: store.snapshot?.root) { _, _ in collapsedCategories.removeAll() }
        .onChange(of: store.selectedProject?.classification.category) { _, category in
            if let category { collapsedCategories.remove(category) }
        }
    }

    private var applicationShell: some View {
        ZStack {
            CinematicBackdrop()
            HStack(spacing: -20) {
                navigationRail
                contentSurface
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: ControlTheme.cornerRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: ControlTheme.cornerRadius, style: .continuous)
                .strokeBorder(Color.black.opacity(0.72), lineWidth: 2).allowsHitTesting(false)
        }
        .animation(reduceMotion ? nil : ControlTheme.navigationMotion, value: sidebarExpanded)
    }

    private var navigationRail: some View {
        VStack(spacing: 12) {
            Button { sidebarExpanded.toggle() } label: {
                HStack(spacing: 10) {
                    railIcon(sidebarExpanded ? ControlConstants.collapseSidebarIcon : ControlConstants.expandSidebarIcon,
                        selected: false)
                    if sidebarExpanded {
                        Text(ControlConstants.appName).font(.system(size: 14, weight: .semibold))
                            .lineLimit(1).transition(.opacity.combined(with: .move(edge: .leading)))
                    }
                }
                .frame(maxWidth: .infinity, alignment: sidebarExpanded ? .leading : .center)
                .contentShape(Rectangle())
            }.buttonStyle(.plain)
                .help(sidebarExpanded ? ControlConstants.collapseNavigation : ControlConstants.expandNavigation)
                .accessibilityLabel(sidebarExpanded ? ControlConstants.collapseNavigation : ControlConstants.expandNavigation)

            if let snapshot = store.snapshot {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        repositoryRow(snapshot)
                        ForEach(Array(snapshot.categories.enumerated()), id: \.element.id) { index, category in
                            categorySection(category, icon: categoryIcon(at: index))
                        }
                    }.padding(.vertical, 4)
                }.scrollIndicators(.hidden)
                Spacer(minLength: 0)
                if sidebarExpanded {
                    VStack(alignment: .leading, spacing: 4) {
                        InstrumentLabel(title: ControlConstants.localOnly).foregroundStyle(ControlTheme.railMuted)
                        Text(ControlConstants.checkCadence).font(.caption2).foregroundStyle(ControlTheme.railMuted)
                            .fixedSize(horizontal: false, vertical: true)
                    }.padding(.horizontal, 8).transition(.opacity)
                }
            } else {
                Spacer(minLength: 0)
            }
        }
        .padding(.horizontal, 12).padding(.bottom, 12).padding(.top, 34).padding(.trailing, 26)
        .frame(width: sidebarExpanded ? 244 : 88)
        .frame(maxHeight: .infinity)
        .foregroundStyle(ControlTheme.railInk)
        .background(ControlTheme.rail, in: RoundedRectangle(cornerRadius: ControlTheme.cornerRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: ControlTheme.cornerRadius, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1).allowsHitTesting(false)
        }.zIndex(0)
    }

    private var contentSurface: some View {
        VStack(spacing: 0) {
            contentHeader
            if let message = store.error { errorBanner(message) }
            if let snapshot = store.snapshot { selectedContent(snapshot) }
            else { connectionPrompt }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            ZStack {
                SceneGlass().opacity(0.54)
                if reduceTransparency {
                    RoundedRectangle(cornerRadius: ControlTheme.cornerRadius, style: .continuous)
                        .fill(ControlTheme.surfaceStrong.opacity(0.98))
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: ControlTheme.cornerRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: ControlTheme.cornerRadius, style: .continuous)
                .stroke(Color.white.opacity(0.52), lineWidth: 1).allowsHitTesting(false)
        }
        .zIndex(1)
    }

    private var contentHeader: some View {
        HStack(spacing: 12) {
            Image(nsImage: NSApplication.shared.applicationIconImage).resizable().interpolation(.high)
                .scaledToFit().frame(width: 34, height: 34).accessibilityHidden(true)
            Text(ControlConstants.appName).font(.system(size: 17, weight: .semibold))
                .lineLimit(1).fixedSize().layoutPriority(2)
            Spacer(minLength: 18)
            if let root = store.snapshot?.root {
                Text(root.lastPathComponent).font(.caption).foregroundStyle(ControlTheme.muted)
                    .lineLimit(1).truncationMode(.middle).help(root.lastPathComponent).layoutPriority(0)
            }
            Button { setLocked(true) } label: {
                Image(systemName: ControlConstants.lockIcon).frame(width: 34, height: 34).contentShape(Rectangle())
            }.buttonStyle(.plain).help(ControlConstants.lockDisplay).accessibilityLabel(ControlConstants.lockDisplay)
            Menu {
                Button(ControlConstants.changeRepository) { store.chooseRepository() }
                Button(ControlConstants.refresh) {
                    if let root = store.snapshot?.root { Task { await store.reload(root) } }
                }.disabled(store.snapshot == nil || store.loading)
            } label: {
                Image(systemName: ControlConstants.menuIcon).frame(width: 34, height: 34).contentShape(Rectangle())
            }.menuStyle(.borderlessButton).menuIndicator(.hidden).fixedSize()
                .help(ControlConstants.repositoryActions).accessibilityLabel(ControlConstants.repositoryActions)
        }
        .padding(.horizontal, 24).frame(height: 66)
        .overlay(alignment: .bottom) { Rectangle().fill(ControlTheme.line).frame(height: 1) }
    }

    /// Shows the selected README surface inside a fixed window-height scroll region.
    /// - Parameter snapshot: Current complete repository snapshot.
    /// - Returns: A project or repository screen whose long content scrolls without resizing the window.
    private func selectedContent(_ snapshot: RepositorySnapshot) -> some View {
        ScrollView {
            Group {
                if let project = store.selectedProject { ProjectScreen(store: store, project: project).id(project.id) }
                else { RepositoryScreen(store: store, snapshot: snapshot).id(snapshot.root.path) }
            }.padding(28).frame(maxWidth: 1050).frame(maxWidth: .infinity)
        }.scrollIndicators(.hidden)
    }

    private var connectionPrompt: some View {
        VStack(alignment: .leading, spacing: 24) {
            Image(systemName: ControlConstants.diamondIcon).font(.system(size: 48, weight: .ultraLight))
            Text(ControlConstants.noRepository).font(.system(size: 38, weight: .light))
            Text(ControlConstants.connectExplanation).font(.body).foregroundStyle(ControlTheme.muted).lineSpacing(5)
            Button(ControlConstants.chooseRepository) { store.chooseRepository() }
                .buttonStyle(.borderedProminent).controlSize(.large).foregroundStyle(ControlTheme.background)
            if store.loading { ProgressView().controlSize(.small) }
        }.frame(maxWidth: 550, alignment: .leading).padding(50).frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    /// Presents a rounded failure surface without changing the current valid snapshot.
    /// - Parameter message: User-readable failure from the store.
    /// - Returns: A dismissible warning banner.
    private func errorBanner(_ message: String) -> some View {
        HStack(alignment: .top) {
            Image(systemName: ControlConstants.warningIcon)
            Text(message).textSelection(.enabled)
            Spacer()
            Button(ControlConstants.dismiss) { store.error = nil }
        }.font(.callout).foregroundStyle(ControlTheme.amber).padding(14)
            .background(ControlTheme.surfaceStrong.opacity(0.82), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .padding(.horizontal, 18).padding(.top, 12)
    }

    /// Keeps the repository parent as a first-class hierarchy node in both rail states.
    /// - Parameter snapshot: Current repository identity and project count.
    /// - Returns: A full-row repository selection control.
    private func repositoryRow(_ snapshot: RepositorySnapshot) -> some View {
        Button { store.selection = snapshot.root.path } label: {
            HStack(spacing: 10) {
                railIcon(ControlConstants.repositoryIcon, selected: store.selection == snapshot.root.path)
                if sidebarExpanded {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(snapshot.root.lastPathComponent).font(.system(size: 13, weight: .semibold)).lineLimit(2)
                        Text(ControlConstants.repositorySummary).font(.caption2).foregroundStyle(ControlTheme.railMuted)
                    }.frame(maxWidth: .infinity, alignment: .leading).transition(.opacity)
                }
            }.frame(maxWidth: .infinity, alignment: sidebarExpanded ? .leading : .center).contentShape(Rectangle())
        }.buttonStyle(.plain).accessibilityAddTraits(store.selection == snapshot.root.path ? .isSelected : [])
    }

    /// Animates every child row when its README-driven category opens or closes.
    /// - Parameters: category: Source-ordered project group. icon: Stable visual marker for this position.
    /// - Returns: A disclosure section in expanded mode or one aligned category control in rail mode.
    private func categorySection(_ category: ProjectCategory, icon: String) -> some View {
        let collapsed = collapsedCategories.contains(category.name)
        return VStack(spacing: 5) {
            Button {
                if sidebarExpanded {
                    if collapsed { collapsedCategories.remove(category.name) }
                    else { collapsedCategories.insert(category.name) }
                } else if let project = category.projects.first { store.selection = project.id }
            } label: {
                HStack(spacing: 10) {
                    railIcon(icon, selected: store.selectedProject?.classification.category == category.name)
                    if sidebarExpanded {
                        Text(category.name).font(.system(size: 12, weight: .semibold)).lineLimit(2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(category.projects.count.formatted()).font(.caption2.monospaced()).foregroundStyle(ControlTheme.railMuted)
                        Image(systemName: collapsed ? ControlConstants.collapsedIcon : ControlConstants.expandedIcon)
                            .font(.system(size: 9, weight: .semibold)).frame(width: 10).accessibilityHidden(true)
                    }
                }
                .frame(maxWidth: .infinity, alignment: sidebarExpanded ? .leading : .center).contentShape(Rectangle())
            }.buttonStyle(.plain).accessibilityValue(collapsed ? ControlConstants.collapsed : ControlConstants.expanded)
            if sidebarExpanded && !collapsed {
                ForEach(Array(category.projects.enumerated()), id: \.element.id) { index, project in
                    projectRow(project).transition(.opacity.combined(with: .move(edge: .top)))
                        .animation(reduceMotion ? nil : ControlTheme.motion.delay(Double(index) * 0.045), value: collapsed)
                }
            }
        }.animation(reduceMotion ? nil : ControlTheme.motion, value: collapsed)
    }

    /// Shows documented scope without adding inferred capabilities or absent tags.
    /// - Parameter project: Registered project with root-owned classification metadata.
    /// - Returns: A compact, fully selectable project row.
    private func projectRow(_ project: ProjectRecord) -> some View {
        Button { store.selection = project.id } label: {
            HStack(alignment: .center, spacing: 10) {
                ProjectIcon(project: project, size: 26).frame(width: 36, height: 36)
                VStack(alignment: .leading, spacing: 3) {
                    Text(project.name).font(.system(size: 12, weight: .medium)).lineLimit(2)
                    if let scope = project.classification.technicalScope {
                        Text(scope).font(.caption2).foregroundStyle(ControlTheme.railMuted).lineLimit(1)
                    }
                }.frame(maxWidth: .infinity, alignment: .leading)
            }.padding(.vertical, 5).padding(.horizontal, 4).contentShape(Rectangle())
                .background(store.selection == project.id ? Color.white.opacity(0.10) : .clear,
                    in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }.buttonStyle(.plain).accessibilityAddTraits(store.selection == project.id ? .isSelected : [])
    }

    /// Centers every collapsed marker on the same rail axis.
    /// - Parameters: name: SF Symbol name. selected: Whether the destination owns the current selection.
    /// - Returns: A fixed-size rounded icon target.
    private func railIcon(_ name: String, selected: Bool) -> some View {
        Image(systemName: name).font(.system(size: 17, weight: .medium))
            .frame(width: 40, height: 40)
            .foregroundStyle(selected ? ControlTheme.background : ControlTheme.railInk)
            .background(selected ? ControlTheme.signal : Color.clear,
                in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .accessibilityHidden(true)
    }

    /// Uses stable position markers without inferring a category's technology or capability.
    /// - Parameter index: Source-order category position.
    /// - Returns: One reusable SF Symbol name.
    private func categoryIcon(at index: Int) -> String {
        ControlConstants.categoryIcons[index % ControlConstants.categoryIcons.count]
    }

    /// Moves between the content shell and artwork without authentication or source changes.
    /// - Parameter locked: True to hide project content; false to restore it.
    /// - Returns: Nothing; changes only the local presentation state.
    private func setLocked(_ locked: Bool) {
        withAnimation(reduceMotion ? nil : ControlTheme.motion) { displayLocked = locked }
    }
}

/// A wrapping informational badge; its appearance does not imply a clickable action or health state.
internal struct ClassificationBadge: View {
    internal let title: String
    internal let value: String

    internal var body: some View {
        Text(value).font(.system(size: 10, weight: .medium)).foregroundStyle(ControlTheme.ink.opacity(0.72))
            .multilineTextAlignment(.leading).fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 8).padding(.vertical, 4)
            .background(Color.white.opacity(0.38), in: Capsule())
            .overlay { Capsule().stroke(ControlTheme.line, lineWidth: 0.7) }
            .help(title + ControlConstants.colon + ControlConstants.space + value)
            .accessibilityElement(children: .ignore).accessibilityLabel(title).accessibilityValue(value)
    }
}

/// Readable, expandable summaries rather than raw Markdown or source files.
internal struct HistoryList: View {
    internal let entries: [HistoryEntry]
    internal var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if entries.isEmpty { Text(ControlConstants.noHistory).foregroundStyle(ControlTheme.muted) }
            ForEach(entries) { entry in
                DisclosureGroup {
                    Text(entry.detail).font(.callout).lineSpacing(4).textSelection(.enabled)
                        .foregroundStyle(ControlTheme.muted).frame(maxWidth: .infinity, alignment: .leading).padding(.vertical, 8)
                } label: { Text(entry.heading).font(.callout.weight(.medium)) }
                    .padding(14).background(Color.white.opacity(0.34), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }.padding(.vertical, 10)
    }
}
