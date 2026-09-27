import SwiftUI

/// A selected project's introduction, documented structure, notes, and source history.
internal struct ProjectScreen: View {
    @ObservedObject internal var store: ControlStore
    internal let project: ProjectRecord
    @State private var tab = ProjectTab.overview
    @State private var editedNote: WorkNote?
    @State private var deletion: WorkNote?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private var notes: [WorkNote] { store.notes(for: project.id) }

    internal var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            hero
            card
            if project.isStale || store.syncFailure != nil {
                Text(ControlConstants.staleContent).font(.callout).foregroundStyle(ControlTheme.amber)
            }
            if let warning = project.sourceWarning {
                Text(warning).font(.caption).foregroundStyle(ControlTheme.amber)
            }
            VStack(alignment: .leading, spacing: 8) {
                TabStrip(tabs: ProjectTab.allCases, label: \.label, selection: $tab)
                Group {
                    switch tab {
                    case .overview: ReadmeContent(blocks: project.overview, empty: ControlConstants.noIntroduction)
                    case .architecture: ReadmeContent(blocks: project.architecture, empty: ControlConstants.noArchitecture)
                    case .models: ReadmeContent(blocks: project.models, empty: ControlConstants.noModels)
                    case .workflows: workflows
                    case .notes: workNotes
                    case .history: HistoryList(entries: project.history)
                    }
                }.transition(.opacity).animation(reduceMotion ? nil : ControlTheme.motion, value: tab)
            }.frame(maxWidth: .infinity, alignment: .leading)
        }
        .alert(ControlConstants.deleteQuestion, isPresented: Binding(get: { deletion != nil }, set: { if !$0 { deletion = nil } })) {
            Button(ControlConstants.cancel, role: .cancel) { deletion = nil }
            Button(ControlConstants.delete, role: .destructive) {
                if let note = deletion { store.delete(note, for: project.id) }
                deletion = nil
            }
        } message: { Text(ControlConstants.deleteExplanation) }
    }

    private var applicationTarget: URL? { store.application(for: project) }

    /// The project's card, laid out the same way for every project: the header, then one full-width strip
    /// of equal columns, so no part of the card is left empty at any width.
    private var card: some View {
        let target = applicationTarget
        return GlassCard(contentPadding: 16) {
            VStack(alignment: .leading, spacing: 14) {
                header(target: target)
                Divider().overlay(ControlTheme.line)
                HStack(alignment: .top, spacing: 24) {
                    healthSummary
                    notesSummary
                    applicationSummary(target: target)
                }
            }
        }
    }

    /// The project's identity on the sky itself, centered above the column: its icon, its name, and the
    /// release with the documented technical scope beneath.
    private var hero: some View {
        let release = project.version ?? (project.usesDatedHistory ? ControlConstants.datedHistory
            : ControlConstants.releaseUnknown)
        return VStack(spacing: 10) {
            ProjectIcon(project: project, size: 52)
            Text(project.name).font(.system(size: 38, weight: .light)).tracking(-1)
                .fixedSize(horizontal: false, vertical: true).accessibilityAddTraits(.isHeader)
            Text(release + (project.classification.technicalScope.map { ControlConstants.joined + $0 }
                ?? ControlConstants.empty))
                .font(.callout.monospaced()).foregroundStyle(ControlTheme.muted)
        }.multilineTextAlignment(.center).frame(maxWidth: .infinity).padding(.bottom, 4)
    }

    /// Keeps one header layout whatever the tag count: the tags wrap on the leading side and the actions
    /// hold the trailing side, so the buttons never move.
    /// - Parameter target: Launch target already resolved for this view update.
    /// - Returns: The card's tag and action row.
    private func header(target: URL?) -> some View {
        HStack(alignment: .center, spacing: 16) {
            TechnologyTagLayout {
                ForEach(project.classification.technologies, id: \.self) { technology in
                    ClassificationBadge(title: ControlConstants.technology, value: technology)
                }
            }.frame(maxWidth: .infinity, alignment: .leading)
            HStack(spacing: 10) { actionControls(target: target) }
                .controlSize(.large).buttonStyle(.bordered).fixedSize()
        }
    }

    /// Builds the folder, README, and launch controls from one resolved launch target.
    /// - Parameter target: Launch target already resolved for this view update.
    /// - Returns: The action buttons of the card's header row.
    @ViewBuilder private func actionControls(target: URL?) -> some View {
        Button { store.open(project.folder) } label: { Label(ControlConstants.folder, systemImage: ControlConstants.folderIcon) }
            .buttonStyle(.borderedProminent).foregroundStyle(ControlTheme.background).disabled(!project.folderAvailable)
        Button { store.open(project.readme) } label: { Label(ControlConstants.read, systemImage: ControlConstants.readIcon) }
            .disabled(!project.readmeAvailable)
        launchControls(target: target)
    }

    /// Offers ambiguous candidates as a menu and keeps the forget-app control beside them.
    /// - Parameter target: Launch target already resolved for this view update.
    /// - Returns: The launch button or candidate menu, with the optional stored-choice menu.
    @ViewBuilder private func launchControls(target: URL?) -> some View {
        if target == nil && project.applications.count > 1 {
            Menu {
                ForEach(project.applications, id: \.self) { application in
                    Button(application.deletingPathExtension().lastPathComponent) {
                        store.launch(project, selectedApp: application)
                    }
                }
            } label: { Label(ControlConstants.launch, systemImage: ControlConstants.playIcon) }
        } else {
            Button { store.launch(project) } label: { Label(ControlConstants.launch, systemImage: ControlConstants.playIcon) }
        }
        if store.state.applications[project.id] != nil {
            Menu {
                Button(ControlConstants.clearApp) { store.clearApplication(for: project.id) }
            } label: { Image(systemName: ControlConstants.menuIcon) }.frame(width: 32)
                .help(ControlConstants.clearApp).disabled(!store.storageReady)
        }
    }

    private var workflows: some View {
        VStack(alignment: .leading, spacing: 24) {
            if project.workflows.isEmpty {
                ContentSurface { Text(ControlConstants.noWorkflow).font(.callout).foregroundStyle(ControlTheme.muted) }
            } else {
                ForEach(project.workflows) { route in
                    VStack(alignment: .leading, spacing: 14) {
                        Text(route.label).font(.headline).textSelection(.enabled)
                        WorkflowDiagram(route: route)
                    }
                }
                ContentSurface { Text(ControlConstants.workflowLegend).font(.caption).foregroundStyle(ControlTheme.muted) }
            }
        }
    }

    private var workNotes: some View {
        ContentSurface {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(ControlConstants.notes).font(.headline)
                        Text(ControlConstants.noteHint).font(.caption).foregroundStyle(ControlTheme.muted)
                    }
                    Spacer(minLength: 12)
                    Button { editedNote = WorkNote(text: ControlConstants.empty) } label: {
                        Label(ControlConstants.addNote, systemImage: ControlConstants.addIcon)
                    }.buttonStyle(.borderedProminent).foregroundStyle(ControlTheme.background)
                        .keyboardShortcut(KeyEquivalent(ControlConstants.keyboardNew))
                        .disabled(!store.storageReady || editedNote != nil)
                }
                if let note = editedNote {
                    NoteEditor(note: Binding(get: { editedNote ?? note }, set: { editedNote = $0 }),
                        onSave: { store.save($0, for: project.id) }, onClose: { editedNote = nil })
                        .id(note.id)
                } else if notes.isEmpty {
                    Text(ControlConstants.emptyNotesDetail).font(.callout).foregroundStyle(ControlTheme.muted)
                }
                ForEach(notes) { note in
                    Divider().overlay(ControlTheme.line)
                    HStack(alignment: .top, spacing: 14) {
                        Text(note.text).font(.system(size: 14)).lineSpacing(4).textSelection(.enabled)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Menu {
                            Button(ControlConstants.edit) { editedNote = note }
                            Button(ControlConstants.delete, role: .destructive) { deletion = note }
                        } label: { Image(systemName: ControlConstants.menuIcon) }
                            .frame(width: 32).disabled(!store.storageReady || editedNote != nil)
                    }
                }
                if !store.storageReady { Text(ControlConstants.notesLocked).foregroundStyle(ControlTheme.amber).font(.callout) }
            }
        }
    }

    private var notesSummary: some View {
        metric(ControlConstants.notesSummary, value: notes.isEmpty ? ControlConstants.noNotes : ControlConstants.notesAvailable,
            tint: notes.isEmpty ? ControlTheme.ink : ControlTheme.mint) { EmptyView() }
    }

    private var healthSummary: some View {
        let available = project.folderAvailable && project.readmeAvailable
        let value = !project.folderAvailable ? ControlConstants.healthFolderMissing
            : project.readmeAvailable ? ControlConstants.healthAvailable : ControlConstants.healthReadmeMissing
        return metric(ControlConstants.documentHealth, value: value, tint: available ? ControlTheme.mint : ControlTheme.amber,
            icon: available ? ControlConstants.completeIcon : ControlConstants.warningIcon) {
            if !project.folderAvailable { Text(ControlConstants.folderMissing) }
            else if !project.readmeAvailable { Text(ControlConstants.noReadme) }
            if !project.isRegistered { Text(ControlConstants.unregisteredProject).foregroundStyle(ControlTheme.amber) }
            Text(ControlConstants.runtimeUnknown)
        }
    }

    /// Reports which app Open App will use, or why it will ask.
    /// - Parameter target: Launch target already resolved for this view update.
    /// - Returns: The App column of the card's summary strip.
    private func applicationSummary(target: URL?) -> some View {
        metric(ControlConstants.applicationSummary, value: target?.lastPathComponent ?? ControlConstants.noValue,
            tint: ControlTheme.ink) {
            Text(target.map { project.applications.contains($0) ? ControlConstants.detectedApp : ControlConstants.appChoice }
                ?? (project.applications.count > 1 ? ControlConstants.appAmbiguous : ControlConstants.appMissing))
        }
    }

    /// Builds one column of the card's summary strip: a small label over a larger value, then any detail.
    /// - Parameters:
    ///   - label: What the column reports.
    ///   - value: The short current value.
    ///   - tint: Colour of the value and its icon.
    ///   - icon: Optional SF Symbol before the value, for a state such as available or missing.
    ///   - detail: Quiet explanatory lines beneath the value.
    /// - Returns: The column, filling its share of the strip.
    private func metric<Detail: View>(_ label: String, value: String, tint: Color, icon: String? = nil,
                                      @ViewBuilder detail: () -> Detail) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(.system(size: 11)).foregroundStyle(ControlTheme.muted)
            HStack(spacing: 6) {
                if let icon { Image(systemName: icon).font(.system(size: 14)).accessibilityHidden(true) }
                Text(value).font(.system(size: 17)).lineLimit(1).truncationMode(.middle)
            }.foregroundStyle(tint)
            VStack(alignment: .leading, spacing: 2) { detail() }
                .font(.caption).foregroundStyle(ControlTheme.muted).fixedSize(horizontal: false, vertical: true)
        }.frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// A wrapping informational badge; its appearance does not imply a clickable action or health state.
private struct ClassificationBadge: View {
    internal let title: String
    internal let value: String

    internal var body: some View {
        // Inline, as plain monospaced text after a small square mark; no pill, so it never reads as a button.
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 1.5).fill(ControlTheme.muted.opacity(0.6)).frame(width: 6, height: 6)
            Text(value).font(.system(size: 11, design: .monospaced)).foregroundStyle(ControlTheme.muted)
                .multilineTextAlignment(.leading).fixedSize(horizontal: false, vertical: true)
        }.padding(.vertical, 3).padding(.trailing, 10)
            .help(title + ControlConstants.colon + ControlConstants.space + value)
            .accessibilityElement(children: .ignore).accessibilityLabel(title).accessibilityValue(value)
    }
}

/// An inline, single-field composer; unsuccessful saves keep the draft visible.
private struct NoteEditor: View {
    @Binding internal var note: WorkNote
    internal let onSave: (WorkNote) -> Bool
    internal let onClose: () -> Void
    @State private var failed = false
    @FocusState private var focused: Bool

    internal var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            TextEditor(text: $note.text).font(.body).scrollContentBackground(.hidden)
                .padding(10).frame(minHeight: 150, maxHeight: 220)
                .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(ControlTheme.line, lineWidth: 1))
                .accessibilityLabel(ControlConstants.noteText).focused($focused)
            Text(ControlConstants.noteLimit).font(.caption)
                .foregroundStyle(note.text.count > ControlConstants.maxNoteLength ? ControlTheme.amber : ControlTheme.muted)
            if failed { Text(ControlConstants.saveFailure).font(.callout).foregroundStyle(ControlTheme.amber) }
            HStack {
                Spacer(minLength: 0)
                Button(ControlConstants.cancel, action: onClose).keyboardShortcut(.cancelAction)
                Button(ControlConstants.save) {
                    if onSave(note) { onClose() } else { failed = true }
                }.keyboardShortcut(.return, modifiers: .command).disabled(!note.isValid)
                    .buttonStyle(.borderedProminent).foregroundStyle(ControlTheme.background)
            }
        }.onAppear { focused = true }
    }
}
