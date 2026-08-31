import AppKit
import SwiftUI

/// Local native entry point; no web server, remote service, or embedded browser.
@main
internal struct ProjectControlApp: App {
    @StateObject private var store = ControlStore()

    /// Gives the local development bundle a normal Dock and menu-bar presence.
    /// - Returns: The configured application entry point.
    internal init() { NSApplication.shared.setActivationPolicy(.regular) }

    internal var body: some Scene {
        Window(ControlConstants.appName, id: ControlConstants.bundleID) {
            ControlWindow(store: store)
                .preferredColorScheme(.dark)
                .frame(minWidth: 900, minHeight: 660)
                .task { await store.observe() }
        }
        .defaultSize(width: 1160, height: 840)
        .windowStyle(.hiddenTitleBar)
        .commands {
            CommandGroup(after: .newItem) {
                Button(ControlConstants.chooseRepository) { store.chooseRepository() }
                    .keyboardShortcut(KeyEquivalent(ControlConstants.keyboardOpen))
                Button(ControlConstants.refresh) {
                    if let root = store.snapshot?.root { Task { await store.reload(root) } }
                }.keyboardShortcut(KeyEquivalent(ControlConstants.keyboardRefresh))
                    .disabled(store.snapshot == nil || store.loading)
            }
        }
    }
}
