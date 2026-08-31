import SwiftUI

/// A selected project's introduction, documented structure, notes, and source history.
internal struct ProjectScreen: View {
    @ObservedObject internal var store: ControlStore
    internal let project: ProjectRecord
    @State private var tab = 0
    @State private var editedNote: WorkNote?
    @State private var deletion: WorkNote?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private var notes: [WorkNote] { store.notes(for: project.id) }

    internal var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack {
                InstrumentLabel(title: ControlConstants.synchronized.uppercased())
                Spacer()
                if store.loading { ProgressView().controlSize(.small) }
                Text(project.folder.lastPathComponent).font(.caption.monospaced()).foregroundStyle(ControlTheme.muted)
            }
            HStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 14) {
                    Text(project.name).font(.system(size: 42, weight: .light)).tracking(-1.3).fixedSize(horizontal: false, vertical: true)
                    Text(project.version ?? ControlConstants.releaseUnknown).font(.callout.monospaced()).foregroundStyle(ControlTheme.signal)
                }
                Spacer(minLength: 0)
                NoteGauge(notes: notes)
            }.padding(25).frame(maxWidth: .infinity, alignment: .leading)
                .background(InstrumentFrame().fill(ControlTheme.surface))
                .overlay(InstrumentFrame().stroke(ControlTheme.line, lineWidth: 1).allowsHitTesting(false))
            Text(project.introduction).font(.system(size: 14)).lineSpacing(5).foregroundStyle(ControlTheme.muted).textSelection(.enabled)
            actions
            HStack(spacing: 24) {
                ForEach(Array([ControlConstants.overview, ControlConstants.notes, ControlConstants.history].enumerated()), id: \.offset) { index, label in
                    Button { tab = index } label: {
                        Text(label).font(.system(size: 13, weight: tab == index ? .semibold : .regular))
                            .foregroundStyle(tab == index ? ControlTheme.ink : ControlTheme.muted)
                            .padding(.vertical, 12)
                            .overlay(alignment: .bottom) { if tab == index { Rectangle().fill(ControlTheme.signal).frame(height: 2) } }
                    }.buttonStyle(.plain).accessibilityAddTraits(tab == index ? .isSelected : [])
                }
                Spacer()
            }.overlay(alignment: .bottom) { Rectangle().fill(ControlTheme.line).frame(height: 1) }
            Group {
                switch tab {
                case 1: workNotes
                case 2: HistoryList(entries: project.history)
                default: overview
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
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Button { store.open(project.folder) } label: { Label(ControlConstants.folder, systemImage: ControlConstants.folderIcon) }
                    .buttonStyle(.borderedProminent).foregroundStyle(ControlTheme.background).disabled(!project.folderAvailable)
                Button { store.open(project.readme) } label: { Label(ControlConstants.read, systemImage: ControlConstants.readIcon) }
                    .disabled(!project.readmeAvailable)
                if store.state.applications[project.id] != nil {
                    Button { store.launch(project) } label: { Label(ControlConstants.launch, systemImage: ControlConstants.playIcon) }
                }
                Menu {
                    Button(ControlConstants.chooseApp) { store.chooseApplication(for: project) }
                    if store.state.applications[project.id] != nil {
                        Button(ControlConstants.clearApp) { store.clearApplication(for: project.id) }
                    }
                } label: { Image(systemName: ControlConstants.menuIcon) }.frame(width: 42).help(ControlConstants.chooseApp).disabled(!store.storageReady)
            }.controlSize(.large).buttonStyle(.bordered)
            if let path = store.state.applications[project.id] {
                Text(ControlConstants.appChoice + ControlConstants.colon + ControlConstants.space + URL(fileURLWithPath: path).lastPathComponent)
                    .font(.caption).foregroundStyle(ControlTheme.muted)
            }
        }
    }

    private var overview: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack { InstrumentLabel(title: ControlConstants.workflow.uppercased()); Spacer() }
            if project.workflows.isEmpty {
                Text(ControlConstants.noWorkflow).font(.callout).foregroundStyle(ControlTheme.muted)
            } else {
                ForEach(project.workflows) { route in
                    DisclosureGroup {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(Array(route.steps.enumerated()), id: \.offset) { index, step in
                                HStack(alignment: .top, spacing: 14) {
                                    Text(String(format: ControlConstants.ordinalFormat, index + 1)).font(.caption.monospaced()).foregroundStyle(ControlTheme.signal)
                                    Text(step).font(.callout).textSelection(.enabled)
                                }.padding(12).frame(maxWidth: .infinity, alignment: .leading)
                                    .background(ControlTheme.signal.opacity(0.035))
                                    .overlay(alignment: .leading) { Rectangle().fill(ControlTheme.line).frame(width: 1) }
                                if index < route.steps.count - 1 {
                                    Image(systemName: ControlConstants.downIcon).font(.caption).foregroundStyle(ControlTheme.signal).padding(.leading, 18).accessibilityHidden(true)
                                }
                            }
                        }.padding(.vertical, 12)
                    } label: { Text(route.label).font(.callout) }
                }
                Text(ControlConstants.workflowLegend).font(.caption).foregroundStyle(ControlTheme.muted)
            }
            Rectangle().fill(ControlTheme.line).frame(height: 1)
            DisclosureGroup {
                VStack(alignment: .leading, spacing: 12) {
                    if project.architecture.isEmpty { Text(ControlConstants.noArchitecture).font(.callout) }
                    ForEach(Array(project.architecture.enumerated()), id: \.offset) { _, fact in
                        HStack(alignment: .top, spacing: 12) {
                            Rectangle().fill(ControlTheme.signal).frame(width: 3, height: 12).padding(.top, 3).accessibilityHidden(true)
                            Text(fact).font(.callout).lineSpacing(4).textSelection(.enabled)
                        }
                    }
                }.foregroundStyle(ControlTheme.muted).padding(.top, 14)
            } label: { Text(ControlConstants.architecture).font(.system(size: 14, weight: .medium)) }
        }
    }

    private var workNotes: some View {
        VStack(alignment: .leading, spacing: 16) {
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
                }.padding(.vertical, 10)
                Rectangle().fill(ControlTheme.line).frame(height: 1)
            }
            if !store.storageReady { Text(ControlConstants.notesLocked).foregroundStyle(ControlTheme.amber).font(.callout) }
        }
    }

    private var health: some View {
        VStack(alignment: .leading, spacing: 10) {
            Rectangle().fill(ControlTheme.line).frame(height: 1)
            HStack {
                InstrumentLabel(title: ControlConstants.documentHealth)
                Spacer()
                Text(ControlConstants.runtimeUnknown).font(.caption).foregroundStyle(ControlTheme.muted)
            }
            Text(!project.folderAvailable ? ControlConstants.folderMissing : project.readmeAvailable ? ControlConstants.available : ControlConstants.noReadme)
                .font(.caption).foregroundStyle(project.readmeAvailable ? ControlTheme.muted : ControlTheme.amber)
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
        }.padding(28).frame(width: 480).foregroundStyle(ControlTheme.ink).background(ControlTheme.surface)
    }
}
