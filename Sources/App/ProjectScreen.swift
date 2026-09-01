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
            GlassCard {
                HStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(alignment: .center, spacing: 18) {
                            ProjectIcon(project: project, size: 60)
                            Text(project.name).font(.system(size: 38, weight: .light)).tracking(-1)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Text(project.version ?? ControlConstants.releaseUnknown).font(.callout.monospaced()).foregroundStyle(ControlTheme.mint)
                            .padding(.leading, 78)
                    }
                    Spacer(minLength: 0)
                    NoteGauge(notes: notes)
                }
            }
            actions
            if project.isStale || store.syncFailure != nil {
                Text(ControlConstants.staleContent).font(.callout).foregroundStyle(ControlTheme.amber)
            }
            if let warning = project.sourceWarning {
                Text(warning).font(.caption).foregroundStyle(ControlTheme.amber)
            }
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
            health
        }
        .sheet(item: $editedNote) { note in
            NoteEditor(note: note) { updated in store.save(updated, for: project.id) }
        }
        .alert(ControlConstants.deleteQuestion, isPresented: Binding(get: { deletion != nil }, set: { if !$0 { deletion = nil } })) {
            Button(ControlConstants.cancel, role: .cancel) { deletion = nil }
            Button(ControlConstants.delete, role: .destructive) {
                if let note = deletion { store.delete(note, for: project.id) }
                deletion = nil
            }
        } message: { Text(ControlConstants.deleteExplanation) }
    }

    private var actions: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
            let target = store.application(for: project)
            HStack(spacing: 10) {
                Button { store.open(project.folder) } label: { Label(ControlConstants.folder, systemImage: ControlConstants.folderIcon) }
                    .buttonStyle(.borderedProminent).foregroundStyle(ControlTheme.background).disabled(!project.folderAvailable)
                Button { store.open(project.readme) } label: { Label(ControlConstants.read, systemImage: ControlConstants.readIcon) }
                    .disabled(!project.readmeAvailable)
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
            }.controlSize(.large).buttonStyle(.bordered)
            Text(target.map { (project.applications.contains($0) ? ControlConstants.detectedApp : ControlConstants.appChoice)
                + ControlConstants.colon + ControlConstants.space + $0.lastPathComponent }
                ?? (project.applications.count > 1 ? ControlConstants.appAmbiguous : ControlConstants.appMissing))
                .font(.caption).foregroundStyle(ControlTheme.muted)
            }
        }
    }

    private var workflows: some View {
        VStack(alignment: .leading, spacing: 24) {
            if project.workflows.isEmpty {
                Text(ControlConstants.noWorkflow).font(.callout).foregroundStyle(ControlTheme.muted)
            } else {
                ForEach(project.workflows) { route in
                    VStack(alignment: .leading, spacing: 14) {
                        Text(route.label).font(.headline).textSelection(.enabled)
                        WorkflowDiagram(route: route)
                    }
                }
                Text(ControlConstants.workflowLegend).font(.caption).foregroundStyle(ControlTheme.muted)
            }
        }
    }

    private var workNotes: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                Text(ControlConstants.noteHint).font(.caption).foregroundStyle(ControlTheme.muted)
                Spacer()
                Button {
                    editedNote = WorkNote(title: ControlConstants.empty, detail: ControlConstants.empty, status: .next)
                } label: { Label(ControlConstants.addNote, systemImage: ControlConstants.addIcon) }
                    .keyboardShortcut(KeyEquivalent(ControlConstants.keyboardNew)).disabled(!store.storageReady)
            }
            if notes.isEmpty {
                Text(ControlConstants.emptyNotes).font(.title3)
                Text(ControlConstants.emptyNotesDetail).font(.callout).foregroundStyle(ControlTheme.muted)
            }
            ForEach(notes) { note in
                HStack(alignment: .top, spacing: 14) {
                    Image(systemName: note.status == .done ? ControlConstants.completeIcon : note.status == .inProgress ? ControlConstants.activeIcon : ControlConstants.nextIcon)
                        .foregroundStyle(note.status == .done ? ControlTheme.mint : note.status == .inProgress ? ControlTheme.amber : ControlTheme.signal).padding(.top, 4)
                    VStack(alignment: .leading, spacing: 7) {
                        Text(note.title).font(.system(size: 14, weight: .medium)).textSelection(.enabled)
                        if !note.detail.isEmpty { Text(note.detail).font(.callout).foregroundStyle(ControlTheme.muted).textSelection(.enabled) }
                    }.frame(maxWidth: .infinity, alignment: .leading)
                    Picker(ControlConstants.noteState, selection: Binding(get: { note.status }, set: { status in
                        var updated = note; updated.status = status; _ = store.save(updated, for: project.id)
                    })) {
                        ForEach(WorkStatus.allCases) { Text($0.label).tag($0) }
                    }.labelsHidden().frame(width: 124).disabled(!store.storageReady)
                    Menu {
                        Button(ControlConstants.edit) { editedNote = note }
                        Button(ControlConstants.delete, role: .destructive) { deletion = note }
                    } label: { Image(systemName: ControlConstants.menuIcon) }.frame(width: 32).disabled(!store.storageReady)
                }.padding(14).background(Color.white.opacity(0.34), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            if !store.storageReady { Text(ControlConstants.notesLocked).foregroundStyle(ControlTheme.amber).font(.callout) }
        }
    }

    private var health: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
            HStack {
                InstrumentLabel(title: ControlConstants.documentHealth)
                Spacer()
                Text(ControlConstants.runtimeUnknown).font(.caption).foregroundStyle(ControlTheme.muted)
            }
            Text(!project.folderAvailable ? ControlConstants.folderMissing : project.readmeAvailable ? ControlConstants.available : ControlConstants.noReadme)
                .font(.caption).foregroundStyle(project.readmeAvailable ? ControlTheme.muted : ControlTheme.amber)
            }
        }.padding(.top, 8)
    }
}

/// A structured note composer; the main surface remains a list of work items.
internal struct NoteEditor: View {
    @State internal var note: WorkNote
    internal let onSave: (WorkNote) -> Bool
    @State private var failed = false
    @Environment(\.dismiss) private var dismiss
    private var valid: Bool { !note.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && note.title.count <= 160 && note.detail.count <= 2000 }

    internal var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(ControlConstants.edit).font(.title2)
            TextField(ControlConstants.noteTitle, text: $note.title, axis: .vertical).textFieldStyle(.roundedBorder).lineLimit(1...3)
            Picker(ControlConstants.noteState, selection: $note.status) {
                ForEach(WorkStatus.allCases) { Text($0.label).tag($0) }
            }.pickerStyle(.segmented)
            Text(ControlConstants.noteDetails).font(.callout)
            TextEditor(text: $note.detail).frame(height: 130).font(.body).border(ControlTheme.line).accessibilityLabel(ControlConstants.noteDetails)
            Text(ControlConstants.noteLimit).font(.caption).foregroundStyle(ControlTheme.muted)
            if failed { Text(ControlConstants.saveFailure).font(.callout).foregroundStyle(ControlTheme.amber) }
            HStack {
                Button(ControlConstants.cancel) { dismiss() }.keyboardShortcut(.cancelAction)
                Spacer()
                Button(ControlConstants.save) {
                    note.title = note.title.trimmingCharacters(in: .whitespacesAndNewlines)
                    if onSave(note) { dismiss() } else { failed = true }
                }.keyboardShortcut(.defaultAction).disabled(!valid).buttonStyle(.borderedProminent).foregroundStyle(ControlTheme.background)
            }
        }.padding(28).frame(width: 480).foregroundStyle(ControlTheme.ink)
            .background(.regularMaterial)
    }
}
