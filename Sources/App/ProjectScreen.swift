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
            HStack {
                InstrumentLabel(title: (store.syncFailure == nil && project.sourceWarning == nil
                    ? ControlConstants.synchronized : ControlConstants.sourceWarning).uppercased())
                Spacer()
                if store.loading { ProgressView().controlSize(.small) }
                Text(project.folder.lastPathComponent).font(.caption.monospaced()).foregroundStyle(ControlTheme.muted)
            }
            GlassCard(contentPadding: 16) {
                VStack(alignment: .leading, spacing: 14) {
                    identity
                    HStack(alignment: .top, spacing: 24) {
                        actions.frame(maxWidth: .infinity, alignment: .leading)
                        summaries
                    }
                }
            }
            if project.isStale || store.syncFailure != nil {
                Text(ControlConstants.staleContent).font(.callout).foregroundStyle(ControlTheme.amber)
            }
            if let warning = project.sourceWarning {
                Text(warning).font(.caption).foregroundStyle(ControlTheme.amber)
            }
            VStack(alignment: .leading, spacing: 8) {
                ScrollView(.horizontal) {
                    HStack(spacing: 20) {
                        ForEach(ProjectTab.allCases) { item in
                            Button { tab = item } label: {
                                Text(item.label).font(.system(size: 13, weight: tab == item ? .semibold : .regular))
                                    .foregroundStyle(tab == item ? ControlTheme.ink : ControlTheme.muted)
                                    .padding(.vertical, 12).contentShape(Rectangle())
                                    .overlay(alignment: .bottom) { if tab == item { Rectangle().fill(ControlTheme.signal).frame(height: 2) } }
                            }.buttonStyle(.plain).accessibilityAddTraits(tab == item ? .isSelected : [])
                        }
                    }
                }.scrollIndicators(.hidden).fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 14)
                    .background(Color.white.opacity(0.30), in: RoundedRectangle(cornerRadius: 13, style: .continuous))
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

    private var identity: some View {
        let iconSize: CGFloat = 48
        let iconSpacing: CGFloat = 14
        return VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .center, spacing: iconSpacing) {
                ProjectIcon(project: project, size: iconSize)
                Text(project.name).font(.system(size: 32, weight: .light)).tracking(-1)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Text(project.version ?? ControlConstants.releaseUnknown).font(.callout.monospaced())
                .foregroundStyle(ControlTheme.mint).padding(.leading, iconSize + iconSpacing)
            if !project.classification.technologies.isEmpty {
                TechnologyTagLayout {
                    ForEach(project.classification.technologies, id: \.self) { technology in
                        ClassificationBadge(title: ControlConstants.technology, value: technology)
                    }
                }.padding(.leading, iconSize + iconSpacing).padding(.top, 6)
            }
        }
    }

    private var actions: some View {
        let target = applicationTarget
        return VStack(alignment: .leading, spacing: 10) {
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 10) { actionControls(target: target) }
                VStack(alignment: .leading, spacing: 10) { actionControls(target: target) }
            }.controlSize(.large).buttonStyle(.bordered)
            Text(target.map { (project.applications.contains($0) ? ControlConstants.detectedApp : ControlConstants.appChoice)
                + ControlConstants.colon + ControlConstants.space + $0.lastPathComponent }
                ?? (project.applications.count > 1 ? ControlConstants.appAmbiguous : ControlConstants.appMissing))
                .font(.caption).foregroundStyle(ControlTheme.muted)
        }
    }

    /// Builds the folder, README, and launch controls from one resolved launch target.
    /// - Parameter target: Launch target already resolved for this view update.
    /// - Returns: The adaptive action row shared by both fitted layouts.
    @ViewBuilder private func actionControls(target: URL?) -> some View {
        Button { store.open(project.folder) } label: { Label(ControlConstants.folder, systemImage: ControlConstants.folderIcon) }
            .buttonStyle(.borderedProminent).foregroundStyle(ControlTheme.background).disabled(!project.folderAvailable)
        Button { store.open(project.readme) } label: { Label(ControlConstants.read, systemImage: ControlConstants.readIcon) }
            .disabled(!project.readmeAvailable)
        HStack(spacing: 10) {
            launchControls(target: target)
        }
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

    private var summaries: some View {
        HStack(alignment: .top, spacing: 24) {
            healthSummary
            VStack(alignment: .leading, spacing: 6) {
                InstrumentLabel(title: ControlConstants.notesSummary)
                Label(notes.isEmpty ? ControlConstants.noNotes : ControlConstants.notesAvailable,
                    systemImage: ControlConstants.noteIcon)
                    .font(.caption.weight(.medium)).foregroundStyle(notes.isEmpty ? ControlTheme.muted : ControlTheme.mint)
            }
        }.fixedSize(horizontal: true, vertical: false)
    }

    private var healthSummary: some View {
        VStack(alignment: .leading, spacing: 6) {
            InstrumentLabel(title: ControlConstants.documentHealth)
            Label(healthMessage, systemImage: project.folderAvailable && project.readmeAvailable
                ? ControlConstants.completeIcon : ControlConstants.warningIcon)
                .font(.caption.weight(.medium))
                .foregroundStyle(project.folderAvailable && project.readmeAvailable ? ControlTheme.mint : ControlTheme.amber)
            Text(ControlConstants.runtimeUnknown).font(.caption).foregroundStyle(ControlTheme.muted)
        }.fixedSize(horizontal: true, vertical: false)
    }

    private var healthMessage: String {
        !project.folderAvailable ? ControlConstants.folderMissing
            : project.readmeAvailable ? ControlConstants.available : ControlConstants.noReadme
    }
}

/// A wrapping informational badge; its appearance does not imply a clickable action or health state.
private struct ClassificationBadge: View {
    internal let title: String
    internal let value: String

    internal var body: some View {
        Text(value).font(.system(size: 11, weight: .medium)).foregroundStyle(ControlTheme.ink)
            .multilineTextAlignment(.leading).fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 8).padding(.vertical, 4)
            .background(Color.white.opacity(0.45), in: Capsule())
            .overlay { Capsule().stroke(ControlTheme.line, lineWidth: 0.7) }
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
                .background(Color.white.opacity(0.34), in: RoundedRectangle(cornerRadius: 12))
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
