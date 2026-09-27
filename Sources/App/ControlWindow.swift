import AppKit
import SwiftUI

/// The layered command surface: animated navigation rail, glass content, and privacy artwork.
internal struct ControlWindow: View {
    @ObservedObject internal var store: ControlStore
    @State private var collapsedCategories: Set<String> = []
    @State private var sidebarExpanded = true
    /// Whether the rail's text is shown; it fades before the rail narrows and after it widens.
    @State private var labelsVisible = true
    /// The category whose project list is open beside its collapsed-rail icon.
    @State private var poppedCategory: String?
    @State private var displayLocked = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    private var bundleVersionLabel: String? {
        guard let version = Bundle.main.object(forInfoDictionaryKey: ControlConstants.marketingVersionKey) as? String,
            let build = Bundle.main.object(forInfoDictionaryKey: ControlConstants.bundleVersionKey) as? String
        else { return nil }
        return String(format: ControlConstants.bundleVersionFormat, version, build)
    }
    /// The rail's expanded-only content: labels, category headers and project rows.
    private var showsLabels: Bool { sidebarExpanded && labelsVisible }

    internal var body: some View {
        ZStack {
            Color.clear
            WindowTransparencyConfigurator().frame(width: 0, height: 0).accessibilityHidden(true)
            if displayLocked {
                LockedArtwork { setLocked(false) }
                    .ignoresSafeArea()
                    .transition(.opacity)
            } else {
                applicationShell
                    .ignoresSafeArea()
                    .transition(.opacity)
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
            ControlTheme.rail
            HStack(spacing: 0) {
                navigationRail
                contentSurface
                    .padding(ControlTheme.detailFrameInset)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(reduceMotion ? nil : ControlTheme.navigationMotion, value: sidebarExpanded)
    }

    private var navigationRail: some View {
        VStack(spacing: 0) {
            if let snapshot = store.snapshot {
                repositoryRow(snapshot).padding(.top, 10)
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 8) {
                        ForEach(Array(snapshot.categories.enumerated()), id: \.element.id) { index, category in
                            categorySection(category, icon: categoryIcon(at: index))
                        }
                    }.padding(.top, 8).padding(.bottom, 12)
                }
                VStack(spacing: 5) {
                    Rectangle().fill(ControlTheme.railMuted.opacity(0.20)).frame(height: 1)
                        .padding(.bottom, 7).accessibilityHidden(true)
                    Button { store.open(snapshot.root.appendingPathComponent(ControlConstants.readme)) } label: {
                        footerActionLabel(icon: ControlConstants.repositoryReadIcon,
                            title: ControlConstants.repositoryRead, opensOutside: true)
                    }.buttonStyle(.plain).help(ControlConstants.openRepositoryReadme)
                        .accessibilityLabel(ControlConstants.openRepositoryReadme)
                    Button { store.chooseRepository() } label: {
                        footerActionLabel(icon: ControlConstants.folderIcon, title: ControlConstants.changeRepository)
                    }.buttonStyle(.plain).help(ControlConstants.changeRepository)
                        .accessibilityLabel(ControlConstants.changeRepository)
                    Button { setLocked(true) } label: {
                        footerActionLabel(icon: ControlConstants.lockIcon, title: ControlConstants.lock)
                    }.buttonStyle(.plain).help(ControlConstants.lockDisplay)
                        .accessibilityLabel(ControlConstants.lockDisplay)
                    Rectangle().fill(ControlTheme.railMuted.opacity(0.20)).frame(height: 1)
                        .padding(.vertical, 6).accessibilityHidden(true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 12)
            } else {
                Spacer(minLength: 0)
            }
            brandFooter(store.snapshot)
        }
        .frame(width: ControlTheme.expandedRailWidth - ControlTheme.railLeadingInset - 18)
        .padding(.leading, ControlTheme.railLeadingInset)
        .padding(.trailing, 18)
        .padding(.bottom, 18).padding(.top, 34)
        .frame(width: sidebarExpanded ? ControlTheme.expandedRailWidth : ControlTheme.collapsedRailWidth,
            alignment: .leading)
        .frame(maxHeight: .infinity, alignment: .top)
        .contentShape(Rectangle()).clipped()
        .foregroundStyle(ControlTheme.railInk)
        .zIndex(0)
    }

    private var contentSurface: some View {
        ZStack(alignment: .topTrailing) {
            // Beneath the content, so content scrolled up to it passes over the pill rather than under it.
            if let snapshot = store.snapshot { statusPill(snapshot).padding(14) }
            VStack(spacing: 0) {
                if let message = store.error { errorBanner(message) }
                if let snapshot = store.snapshot { selectedContent(snapshot) }
                else { connectionPrompt }
            }
        }
        // Light text and dark system controls, to suit the smoked glass.
        .environment(\.colorScheme, .dark)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            if reduceTransparency {
                RoundedRectangle(cornerRadius: ControlTheme.detailCornerRadius, style: .continuous)
                    .fill(ControlTheme.skyTop)
            } else {
                // Anchored to the window rather than the surface, so the rail uncovers the clouds as it closes.
                GeometryReader { proxy in
                    let frame = proxy.frame(in: .global)
                    SkyBackdrop()
                        .frame(width: frame.maxX + ControlTheme.detailFrameInset,
                            height: frame.maxY + ControlTheme.detailFrameInset)
                        .offset(x: -frame.minX, y: -frame.minY)
                }
                // Clipping hides the part under the rail but would not stop it taking the rail's clicks.
                .allowsHitTesting(false)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: ControlTheme.detailCornerRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: ControlTheme.detailCornerRadius, style: .continuous)
                .strokeBorder(ControlTheme.rail, lineWidth: ControlTheme.detailFrameWidth)
                .allowsHitTesting(false)
        }
        .zIndex(1)
    }

    /// Shows the selected README surface inside a fixed window-height scroll region.
    /// - Parameter snapshot: Current complete repository snapshot.
    /// - Returns: A project or repository screen whose long content scrolls without resizing the window.
    private func selectedContent(_ snapshot: RepositorySnapshot) -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            Group {
                if let project = store.selectedProject { ProjectScreen(store: store, project: project).id(project.id) }
                else { RepositoryScreen(store: store, snapshot: snapshot).id(snapshot.root.path) }
            }.padding(.horizontal, 28).padding(.top, 56).padding(.bottom, 28)
                .frame(maxWidth: ControlTheme.readingColumnWidth).frame(maxWidth: .infinity)
        }
    }

    /// Reports what the detail shows — the read time on the repository screen, the README state and folder on
    /// a project's — in a small read-only pill pinned to the top corner, beneath the content that scrolls over it.
    /// - Parameter snapshot: Current repository snapshot.
    /// - Returns: The status pill, with a spinner while a read is in progress.
    private func statusPill(_ snapshot: RepositorySnapshot) -> some View {
        let status: String
        if let project = store.selectedProject {
            status = (store.syncFailure == nil && project.sourceWarning == nil
                ? ControlConstants.synchronized : ControlConstants.sourceWarning)
                + ControlConstants.joined + project.folder.lastPathComponent
        } else {
            status = ControlConstants.lastRead + ControlConstants.space
                + snapshot.readAt.formatted(date: .omitted, time: .standard)
        }
        return HStack(spacing: 6) {
            if store.loading { ProgressView().controlSize(.mini) }
            Text(status).font(.caption.monospaced()).foregroundStyle(ControlTheme.muted).lineLimit(1)
        }.padding(.horizontal, 12).padding(.vertical, 6).glassPlane(radius: 13)
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
            .glassPlane(radius: 12)
            .padding(.horizontal, 18).padding(.top, 12)
    }

    /// Pins the repository parent above the scrolling projects. Its icon and name collapse or expand the
    /// rail, the name row ends in the number of listed projects, and the summary line beneath the name
    /// opens the repository's own screen.
    /// - Parameter snapshot: Current repository identity.
    /// - Returns: The repository row, or its icon alone in rail mode.
    private func repositoryRow(_ snapshot: RepositorySnapshot) -> some View {
        let selected = store.selection == snapshot.root.path
        let toggle = sidebarExpanded ? ControlConstants.collapseNavigation : ControlConstants.expandNavigation
        let count = snapshot.projects.count
        let countLabel = String(format: count == 1 ? ControlConstants.singleProjectCountFormat
            : ControlConstants.projectCountFormat, count)
        return HStack(spacing: 10) {
            Button(action: toggleRail) {
                railIcon(ControlConstants.repositoryIcon, selected: selected).contentShape(Rectangle())
            }.buttonStyle(.plain).help(toggle).accessibilityLabel(toggle)
                // Expanded, the name below carries the same action for assistive technologies.
                .accessibilityHidden(showsLabels)
            if showsLabels {
                VStack(alignment: .leading, spacing: 3) {
                    Button(action: toggleRail) {
                        // The total of every listed project, styled like each category's count below it.
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Text(snapshot.root.lastPathComponent).font(.system(size: 13, weight: .semibold)).lineLimit(2)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text(count.formatted()).font(.caption2.monospaced()).foregroundStyle(ControlTheme.railMuted)
                                .help(countLabel)
                        }.contentShape(Rectangle())
                    }.buttonStyle(.plain).help(toggle)
                        .accessibilityLabel(snapshot.root.lastPathComponent).accessibilityValue(countLabel)
                        .accessibilityHint(toggle)
                    Button { store.selection = snapshot.root.path } label: {
                        Text(ControlConstants.repositorySummary).font(.caption2)
                            .foregroundStyle(selected ? ControlTheme.railInk : ControlTheme.railMuted)
                            .frame(maxWidth: .infinity, alignment: .leading).contentShape(Rectangle())
                    }.buttonStyle(.plain).help(ControlConstants.openRepositoryScreen)
                        .accessibilityLabel(ControlConstants.openRepositoryScreen)
                        .accessibilityAddTraits(selected ? .isSelected : [])
                }.transition(.opacity)
            }
        }.frame(maxWidth: .infinity, alignment: .leading)
    }

    /// Signs the rail below its actions with the brand, the live bundle version and the refresh cadence.
    /// The brand is a fixed mark, not a control; in rail mode only its icon remains, on the icon axis.
    /// - Parameter snapshot: Current repository, or nil before one is chosen, when there is nothing to refresh.
    /// - Returns: The brand icon, name, version and refresh lines, and the Refresh now button.
    private func brandFooter(_ snapshot: RepositorySnapshot?) -> some View {
        HStack(spacing: 10) {
            Image(nsImage: NSApplication.shared.applicationIconImage)
                .resizable().interpolation(.high).scaledToFit()
                .frame(width: 30, height: 30)
                .frame(width: ControlTheme.railIconSize, height: ControlTheme.railIconSize)
                .accessibilityHidden(true)
            if showsLabels {
                // One line each: the name, the version and build, then the refresh cadence.
                VStack(alignment: .leading, spacing: 2) {
                    Text(ControlConstants.appName).font(.system(size: 12, weight: .semibold)).lineLimit(1)
                    if let bundleVersionLabel {
                        Text(bundleVersionLabel).font(.caption2).foregroundStyle(ControlTheme.railMuted).lineLimit(1)
                    }
                    if snapshot != nil {
                        Text(ControlConstants.readmeSyncCadence).font(.caption2).foregroundStyle(ControlTheme.railMuted)
                            .lineLimit(1).help(ControlConstants.readmeSyncExplanation)
                    }
                }.frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityElement(children: .combine).transition(.opacity)
                if let snapshot {
                    Button { Task { await store.reload(snapshot.root) } } label: {
                        Image(systemName: ControlConstants.refreshIcon).font(.system(size: 12, weight: .medium))
                            .frame(width: 24, height: 24).contentShape(Rectangle())
                    }.buttonStyle(.plain).disabled(store.loading)
                        .help(ControlConstants.refresh).accessibilityLabel(ControlConstants.refresh)
                        .transition(.opacity)
                }
            }
        }.frame(maxWidth: .infinity, alignment: .leading)
    }

    /// Opens or closes the rail in two steps, closing any category list that belongs to the collapsed rail:
    /// closing fades the labels before the rail narrows, and opening widens the rail before they return.
    /// - Returns: Nothing; changes only local presentation state.
    private func toggleRail() {
        poppedCategory = nil
        if reduceMotion {
            sidebarExpanded.toggle()
            labelsVisible = sidebarExpanded
        } else if sidebarExpanded {
            withAnimation(.easeOut(duration: ControlTheme.railLabelFade)) { labelsVisible = false }
            DispatchQueue.main.asyncAfter(deadline: .now() + ControlTheme.railLabelFade) {
                withAnimation(ControlTheme.navigationMotion) { sidebarExpanded = false }
            }
        } else {
            withAnimation(ControlTheme.navigationMotion) { sidebarExpanded = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + ControlTheme.railLabelDelay) {
                withAnimation(.easeIn(duration: ControlTheme.railLabelFade)) { labelsVisible = true }
            }
        }
    }

    /// Animates every child row when its README-driven category opens or closes.
    /// - Parameters:
    ///   - category: Source-ordered project group.
    ///   - icon: Stable visual marker for this position, shown only in rail mode.
    /// - Returns: A quiet disclosure header in expanded mode, or in rail mode one aligned category control
    ///   that lists the category's projects beside it.
    private func categorySection(_ category: ProjectCategory, icon: String) -> some View {
        let collapsed = collapsedCategories.contains(category.name)
        return VStack(spacing: 5) {
            Button {
                if showsLabels {
                    if collapsed { collapsedCategories.remove(category.name) }
                    else { collapsedCategories.insert(category.name) }
                } else {
                    poppedCategory = poppedCategory == category.name ? nil : category.name
                }
            } label: {
                HStack(spacing: 10) {
                    if showsLabels {
                        Image(systemName: collapsed ? ControlConstants.collapsedIcon : ControlConstants.expandedIcon)
                            .font(.system(size: 9, weight: .semibold)).frame(width: ControlTheme.railIconSize)
                            .accessibilityHidden(true)
                        Text(category.name).font(.system(size: 11, weight: .semibold))
                            .lineLimit(2).frame(maxWidth: .infinity, alignment: .leading)
                        Text(category.projects.count.formatted()).font(.caption2.monospaced())
                    } else {
                        // Anchored to the icon, not the button, whose frame keeps the expanded rail's width.
                        railIcon(icon, selected: store.selectedProject?.classification.category == category.name)
                            .popover(isPresented: popoverBinding(category.name), arrowEdge: .trailing) {
                                categoryPopover(category)
                            }
                    }
                }
                .foregroundStyle(showsLabels ? ControlTheme.railMuted : ControlTheme.railInk)
                .frame(maxWidth: .infinity, minHeight: 28, alignment: .leading).contentShape(Rectangle())
            }.buttonStyle(.plain).accessibilityLabel(category.name + ControlConstants.joined
                + String(category.projects.count))
                .accessibilityValue(showsLabels ? (collapsed ? ControlConstants.collapsed : ControlConstants.expanded)
                    : ControlConstants.empty)
                .accessibilityHint(showsLabels ? ControlConstants.empty : ControlConstants.showCategoryProjects)
                .help(showsLabels ? ControlConstants.empty : category.name)
            if showsLabels && !collapsed {
                ForEach(Array(category.projects.enumerated()), id: \.element.id) { index, project in
                    projectRow(project).transition(.opacity)
                        .animation(reduceMotion ? nil : ControlTheme.motion.delay(Double(index) * 0.045), value: collapsed)
                }
            }
        }.animation(reduceMotion ? nil : ControlTheme.motion, value: collapsed)
    }

    /// Shows the project's name, notes availability, and documented scope; its tags stay on its detail card.
    /// - Parameter project: Registered project with root-owned classification metadata.
    /// - Returns: A compact, fully selectable project row.
    private func projectRow(_ project: ProjectRecord) -> some View {
        Button { store.selection = project.id } label: {
            HStack(alignment: .center, spacing: 10) {
                ProjectIcon(project: project, size: 26).frame(width: 36, height: 36)
                VStack(alignment: .leading, spacing: 3) {
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text(project.name).font(.system(size: 12, weight: .medium)).lineLimit(2)
                        if !store.notes(for: project.id).isEmpty {
                            Image(systemName: ControlConstants.noteIcon).font(.caption2)
                                .foregroundStyle(ControlTheme.railMuted)
                                .accessibilityLabel(ControlConstants.notesAvailable)
                        }
                    }
                    if let scope = project.classification.technicalScope {
                        Text(scope).font(.caption2).foregroundStyle(ControlTheme.railMuted).lineLimit(1)
                    }
                }.frame(maxWidth: .infinity, alignment: .leading)
            }.padding(.vertical, 5).padding(.horizontal, 4).contentShape(Rectangle())
                .background(store.selection == project.id ? Color.white.opacity(0.10) : .clear,
                    in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }.buttonStyle(.plain).accessibilityAddTraits(store.selection == project.id ? .isSelected : [])
    }

    /// Keeps at most one collapsed-rail category list open, and none while the rail is expanded.
    /// - Parameter name: Category whose list the binding controls.
    /// - Returns: A binding that is true only while that category's list is open.
    private func popoverBinding(_ name: String) -> Binding<Bool> {
        Binding(get: { !showsLabels && poppedCategory == name },
            set: { isPresented in if !isPresented && poppedCategory == name { poppedCategory = nil } })
    }

    /// Lists one category's projects beside its collapsed-rail icon, so every project stays one choice away.
    /// - Parameter category: The category whose icon was clicked.
    /// - Returns: A popover list; choosing a project selects it, closes the list and leaves the rail collapsed.
    private func categoryPopover(_ category: ProjectCategory) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(category.name).font(.system(size: 11, weight: .semibold))
                Spacer(minLength: 12)
                Text(category.projects.count.formatted()).font(.caption2.monospaced())
            }.foregroundStyle(Color.secondary).padding(.horizontal, 8).padding(.bottom, 4)
                .accessibilityElement(children: .combine).accessibilityAddTraits(.isHeader)
            ForEach(category.projects) { project in
                Button {
                    poppedCategory = nil
                    store.selection = project.id
                } label: {
                    HStack(spacing: 10) {
                        ProjectIcon(project: project, size: 20).frame(width: 24, height: 24)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(project.name).font(.system(size: 12, weight: .medium)).lineLimit(1)
                            if let scope = project.classification.technicalScope {
                                Text(scope).font(.caption2).foregroundStyle(Color.secondary).lineLimit(1)
                            }
                        }
                        Spacer(minLength: 0)
                    }.padding(.vertical, 5).padding(.horizontal, 8).contentShape(Rectangle())
                        .background(store.selection == project.id ? Color.primary.opacity(0.08) : .clear,
                            in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                }.buttonStyle(.plain).accessibilityAddTraits(store.selection == project.id ? .isSelected : [])
            }
        }.padding(10).frame(width: 260, alignment: .leading)
            // The popover sits on system material, not on the black rail. `Color.primary` is the system
            // label color; the hierarchical `.primary` would resolve to the rail's light ink it inherits.
            .foregroundStyle(Color.primary)
    }

    /// Centers every collapsed marker on the same rail axis.
    /// - Parameters:
    ///   - name: SF Symbol name.
    ///   - selected: Whether the destination owns the current selection.
    /// - Returns: A fixed-size rounded icon target.
    private func railIcon(_ name: String, selected: Bool) -> some View {
        Image(systemName: name).font(.system(size: 17, weight: .medium))
            .frame(width: ControlTheme.railIconSize, height: ControlTheme.railIconSize)
            .foregroundStyle(selected ? Color.white : ControlTheme.railInk.opacity(0.82))
            .accessibilityHidden(true)
    }

    /// Builds one stable footer row so every footer button shares the same icon and label axis.
    /// - Parameters:
    ///   - icon: SF Symbol name rendered in the fixed rail icon column.
    ///   - title: Visible action label shown only while navigation is expanded.
    ///   - opensOutside: True when the action opens another application, marked by a trailing arrow.
    /// - Returns: A full-width footer label with consistent spacing and alignment.
    private func footerActionLabel(icon: String, title: String, opensOutside: Bool = false) -> some View {
        HStack(spacing: 10) {
            railIcon(icon, selected: false)
            if showsLabels {
                Text(title).font(.system(size: 12, weight: .medium))
                    .lineLimit(1).frame(maxWidth: .infinity, alignment: .leading).transition(.opacity)
                if opensOutside {
                    Image(systemName: ControlConstants.readIcon).font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(ControlTheme.railMuted).padding(.trailing, 6)
                        .accessibilityHidden(true).transition(.opacity)
                }
            }
        }.frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(ControlTheme.railInk).contentShape(Rectangle())
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
