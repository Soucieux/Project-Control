import AppKit
import SwiftUI

/// Window checks of the rail's and the history cards' two-step motion, and checks of the project icon cache the
/// window draws from. SwiftUI keeps no inspectable view tree in-process, so the suite drives the real
/// `ControlWindow` with clicks and judges it from captures of its own window. It reads the live repository, opens
/// no application and runs apart from `make test`.
@main
internal enum InterfaceTests {
    /// Starts AppKit; the checks run once it has finished launching.
    /// - Returns: Nothing; the process exits when the checks end.
    internal static func main() {
        let application = NSApplication.shared
        application.setActivationPolicy(.regular)
        let delegate = InterfaceTestsDelegate()
        application.delegate = delegate
        application.run()
    }
}

/// Runs the checks inside the application's run loop, which the window needs to draw and take clicks.
private final class InterfaceTestsDelegate: NSObject, NSApplicationDelegate {
    /// Runs every check and exits.
    /// - Parameter notification: The launch notification.
    /// - Returns: Nothing; exits successfully after the last check or terminates on the first failure.
    internal func applicationDidFinishLaunching(_ notification: Notification) {
        Task { @MainActor in
            do { try await InterfaceRun.run() }
            catch { TestSupport.fail(String(describing: error)) }
            print(TestConstants.interfacePassed + String(TestSupport.count))
            exit(0)
        }
    }
}

/// One scripted session at the minimum window size, with its state in a disposable folder.
@MainActor
private enum InterfaceRun {
    /// Checks the project icon cache, then opens the window on the live repository and asks for the rail and a
    /// history card in quick succession.
    /// - Returns: Nothing; terminates on the first failed check.
    /// - Throws: A file error when the disposable folder or its project folder cannot be created or changed.
    internal static func run() async throws {
        let root = try TestSupport.temporaryFolder()
        defer { TestSupport.removeTemporaryFolder() }
        try iconChecks(root)
        let preferences = TestSupport.preferences(in: root)
        let store = ControlStore(storage: WorkspaceStorage(file: root.appendingPathComponent(ControlConstants.stateFile)),
                                 preferences: preferences)
        await store.reload(URL(fileURLWithPath: TestConstants.liveRoot))
        TestSupport.check(store.snapshot != nil, TestConstants.checkInterfaceRepository)
        let screen = InterfaceWindow(store: store, folder: root)
        defer { screen.window.close() }
        await pause(TestConstants.settleMilliseconds)
        await railChecks(screen)
        await historyChecks(screen)
    }

    /// Fetches a project folder's icon twice, then changes the folder each way its icon can change and fetches the
    /// icon after each change.
    /// - Parameter root: Disposable folder that receives the project folder.
    /// - Returns: Nothing; terminates if an unchanged folder fetches its icon again or a changed one reuses it.
    /// - Throws: A file error when the project folder cannot be created or its metadata changed.
    private static func iconChecks(_ root: URL) throws {
        let folder = root.appendingPathComponent(TestConstants.project)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let project = ProjectRecord(id: folder.resolvingSymlinksInPath().standardizedFileURL.path,
            name: TestConstants.project, folder: folder, readme: folder.appendingPathComponent(ControlConstants.readme),
            introduction: ControlConstants.empty, version: nil, architecture: [], workflows: [], history: [],
            folderAvailable: true, readmeAvailable: false)
        let plain = FolderIcons.icon(for: project)
        TestSupport.check(FolderIcons.icon(for: project) === plain, TestConstants.checkIconReuse)
        let customized = try refetches(project, after: plain, TestConstants.checkIconSet) {
            NSWorkspace.shared.setIcon(swatch(.systemBlue), forFile: folder.path, options: [])
        }
        let replaced = try refetches(project, after: customized, TestConstants.checkIconReplace) {
            NSWorkspace.shared.setIcon(swatch(.systemRed), forFile: folder.path, options: [])
        }
        let iconFile = folder.appendingPathComponent(ControlConstants.customIconFile)
        let fileChanged = try refetches(project, after: replaced, TestConstants.checkIconFileChange) {
            try FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: iconFile.path)
            return true
        }
        let labelled = try refetches(project, after: fileChanged, TestConstants.checkIconFolderChange) {
            try (folder as NSURL).setResourceValue(2, forKey: .labelNumberKey)
            return true
        }
        let removed = try refetches(project, after: labelled, TestConstants.checkIconRemove) {
            NSWorkspace.shared.setIcon(nil, forFile: folder.path, options: [])
        }
        TestSupport.check(FolderIcons.icon(for: project) === removed, TestConstants.checkIconReuse)
    }

    /// Makes one change to a project folder and fetches its icon again.
    /// - Parameters:
    ///   - project: The project whose folder changes.
    ///   - last: The icon fetched before the change.
    ///   - label: What the check proves.
    ///   - change: The change; returns false when it could not be made.
    /// - Returns: The icon fetched after the change; terminates if the change failed or the earlier icon came back.
    /// - Throws: The change's file error.
    private static func refetches(_ project: ProjectRecord, after last: NSImage, _ label: String,
                                  _ change: () throws -> Bool) throws -> NSImage {
        let changed = try change()
        let icon = FolderIcons.icon(for: project)
        TestSupport.check(changed && icon !== last, label)
        return icon
    }

    /// Draws a plain square to set as a custom folder icon.
    /// - Parameter color: Its fill.
    /// - Returns: The image.
    private static func swatch(_ color: NSColor) -> NSImage {
        NSImage(size: NSSize(width: 64, height: 64), flipped: false) { rect in
            color.setFill()
            rect.fill()
            return true
        }
    }

    /// Clicks the rail's toggle once and twice in quick succession from both states.
    /// - Parameter screen: The test window.
    /// - Returns: Nothing; terminates if the rail ends in a state other than the one last asked for.
    private static func railChecks(_ screen: InterfaceWindow) async {
        let toggle = TestConstants.railTogglePoint
        TestSupport.check(screen.railExpanded(), TestConstants.checkRailStart)
        await screen.clicks(toggle, count: 2)
        TestSupport.check(screen.railExpanded(), TestConstants.checkRailDoubleExpanded)
        await screen.clicks(toggle, count: 1)
        TestSupport.check(!screen.railExpanded(), TestConstants.checkRailCollapse)
        await screen.clicks(toggle, count: 2)
        TestSupport.check(!screen.railExpanded(), TestConstants.checkRailDoubleCollapsed)
        await screen.clicks(toggle, count: 1)
        TestSupport.check(screen.railExpanded(), TestConstants.checkRailExpand)
    }

    /// Opens the repository history, finds the strip and the first card below it, and asks the card to open and
    /// close in quick succession.
    /// - Parameter screen: The test window.
    /// - Returns: Nothing; terminates if the strip or the card is missing, or the card ends in a state other than the
    ///   one last asked for.
    private static func historyChecks(_ screen: InterfaceWindow) async {
        await screen.clicks(TestConstants.historyTabPoint, count: 1)
        let stripTop = screen.cardTop()
        TestSupport.check(stripTop != nil, TestConstants.checkHistoryStrip)
        guard let stripTop else { return }
        let top = screen.cardTop(from: stripTop + screen.cardHeight(top: stripTop) + TestConstants.probeMargin)
        TestSupport.check(top != nil, TestConstants.checkHistoryCard)
        guard let top else { return }
        let closed = screen.cardHeight(top: top)
        let header = CGPoint(x: TestConstants.cardHeaderX, y: top + TestConstants.cardHeaderOffset)
        await screen.clicks(header, count: 3)
        TestSupport.check(screen.cardHeight(top: top) > closed + TestConstants.cardGrowth, TestConstants.checkHistoryReopen)
        await screen.clicks(header, count: 1, settle: TestConstants.cardCloseMilliseconds)
        TestSupport.check(screen.cardHeight(top: top) < closed + TestConstants.cardClosedTolerance,
                          TestConstants.checkHistoryClose)
        await screen.clicks(header, count: 2, settle: TestConstants.cardCloseMilliseconds)
        TestSupport.check(screen.cardHeight(top: top) < closed + TestConstants.cardClosedTolerance,
                          TestConstants.checkHistoryOpenClose)
    }

    /// Waits without blocking the run loop.
    /// - Parameter milliseconds: How long to wait.
    /// - Returns: Nothing; returns early only if the task is cancelled.
    internal static func pause(_ milliseconds: Int) async {
        try? await Task.sleep(for: .milliseconds(milliseconds))
    }
}

/// Accepts a click without the window needing focus first, as the first click of a real session does.
private final class FirstClickHostingView: NSHostingView<AnyView> {
    /// Lets the first click act on the view.
    /// - Parameter event: The click.
    /// - Returns: Always true.
    internal override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }
}

/// The real window content at the minimum size, with clicks and captures measured from its top-left corner.
@MainActor
private struct InterfaceWindow {
    /// One capture's pixels as 8-bit sRGB rows, top row first.
    private struct Capture {
        internal let bytes: [UInt8]
        internal let width: Int
        internal let height: Int
    }

    internal let window: NSWindow
    private let folder: URL

    /// Opens the window the app itself composes, above other windows so its captures are never occluded.
    /// - Parameters:
    ///   - store: The store the window shows.
    ///   - folder: The run's disposable folder, which receives the captures.
    /// - Returns: The shown window's wrapper.
    internal init(store: ControlStore, folder: URL) {
        let content = ControlWindow(store: store).preferredColorScheme(.light)
            .frame(minWidth: ControlTheme.minimumWindowWidth, minHeight: ControlTheme.minimumWindowHeight)
        let frame = NSRect(origin: TestConstants.windowOrigin,
                           size: NSSize(width: ControlTheme.minimumWindowWidth, height: ControlTheme.minimumWindowHeight))
        window = NSWindow(contentRect: frame, styleMask: [.titled, .closable, .resizable, .fullSizeContentView],
                          backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.contentView = FirstClickHostingView(rootView: AnyView(content))
        window.level = .floating
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        self.folder = folder
    }

    /// Clicks one point several times in quick succession, then waits for the motion to settle.
    /// - Parameters:
    ///   - point: Window point from the top-left corner.
    ///   - count: Number of clicks.
    ///   - settle: Wait after the last click.
    /// - Returns: Nothing; the window has handled every click.
    internal func clicks(_ point: CGPoint, count: Int, settle: Int = TestConstants.railSettleMilliseconds) async {
        for index in 0..<count {
            if index > 0 { await InterfaceRun.pause(TestConstants.quickClickMilliseconds) }
            let location = NSPoint(x: point.x, y: window.frame.height - point.y)
            for type in [NSEvent.EventType.leftMouseDown, .leftMouseUp] {
                if let event = NSEvent.mouseEvent(with: type, location: location, modifierFlags: [],
                                                  timestamp: ProcessInfo.processInfo.systemUptime,
                                                  windowNumber: window.windowNumber, context: nil,
                                                  eventNumber: 0, clickCount: 1, pressure: 1) {
                    window.sendEvent(event)
                }
            }
        }
        await InterfaceRun.pause(settle)
    }

    /// Reads whether the rail is open from the black of its trailing padding.
    /// - Returns: True when every probe point just inside the open rail's edge is dark.
    internal func railExpanded() -> Bool {
        let image = capture()
        return TestConstants.railProbeRows.allSatisfy {
            luminance(image, x: TestConstants.railProbeX, y: $0) < TestConstants.railDarkness
        }
    }

    /// Finds the first glass top edge at or below a point, the tabs' bottom by default.
    /// - Parameter start: The window point to search down from.
    /// - Returns: The top edge in window points, or nil when no glass is found above the window's bottom margin.
    internal func cardTop(from start: CGFloat = TestConstants.cardSearch.lowerBound) -> CGFloat? {
        let image = capture()
        let x = TestConstants.cardProbeX
        return stride(from: start, to: window.frame.height - TestConstants.probeMargin, by: 1).first {
            luminance(image, x: x, y: $0) < TestConstants.glassDarkness
                && luminance(image, x: x, y: $0 + TestConstants.probeMargin) < TestConstants.glassDarkness
        }
    }

    /// Measures how far the card's glass runs down before the sky shows again.
    /// - Parameter top: The card's top edge.
    /// - Returns: The card's height in window points.
    internal func cardHeight(top: CGFloat) -> CGFloat {
        let image = capture()
        var y = top
        while y < window.frame.height - TestConstants.probeMargin
            && luminance(image, x: TestConstants.cardProbeX, y: y) < TestConstants.glassDarkness { y += 1 }
        return y - top
    }

    /// Captures the window alone, without its shadow, into the run's folder.
    /// - Returns: The capture's pixels; terminates when the window cannot be captured.
    private func capture() -> Capture {
        let file = folder.appendingPathComponent(TestConstants.captureName)
        try? FileManager.default.removeItem(at: file)
        let process = Process()
        process.executableURL = URL(fileURLWithPath: TestConstants.screenCapture)
        process.arguments = TestConstants.screenCaptureOptions + [String(window.windowNumber), file.path]
        try? process.run()
        process.waitUntilExit()
        guard let source = CGImageSourceCreateWithURL(file as CFURL, nil),
              let picture = CGImageSourceCreateImageAtIndex(source, 0, nil),
              let space = CGColorSpace(name: CGColorSpace.sRGB) else {
            TestSupport.fail(TestConstants.checkInterfaceCapture)
        }
        var bytes = [UInt8](repeating: 0, count: picture.width * picture.height * 4)
        let drawn = bytes.withUnsafeMutableBytes { buffer -> Bool in
            guard let context = CGContext(data: buffer.baseAddress, width: picture.width, height: picture.height,
                                          bitsPerComponent: 8, bytesPerRow: picture.width * 4, space: space,
                                          bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return false }
            context.draw(picture, in: CGRect(x: 0, y: 0, width: picture.width, height: picture.height))
            return true
        }
        TestSupport.check(drawn, TestConstants.checkInterfaceCapture)
        return Capture(bytes: bytes, width: picture.width, height: picture.height)
    }

    /// Reads a capture's relative luminance, by the sRGB weights, at a window point.
    /// - Parameters:
    ///   - image: The capture.
    ///   - x: Window point from the leading edge.
    ///   - y: Window point from the top edge.
    /// - Returns: Luminance from 0 (black) to 1 (white).
    private func luminance(_ image: Capture, x: CGFloat, y: CGFloat) -> CGFloat {
        let scale = CGFloat(image.width) / window.frame.width
        let column = min(image.width - 1, Int(x * scale))
        let row = min(image.height - 1, Int(y * scale))
        let offset = (row * image.width + column) * 4
        let red = CGFloat(image.bytes[offset])
        let green = CGFloat(image.bytes[offset + 1])
        let blue = CGFloat(image.bytes[offset + 2])
        return (0.2126 * red + 0.7152 * green + 0.0722 * blue) / 255
    }
}
