import Cocoa
import ApplicationServices
import Carbon.HIToolbox

// Snap Cat — left/right halves + fill + minimize via Accessibility (Rectangle's core, ~nothing else)

enum SnapAction { case left, right, fill, minimize }

// MARK: - AX

enum AX {
    private static var didPrompt = false

    /// `prompt` only once at launch — never on hotkey (spam).
    static func ensureTrusted(prompt: Bool = false) -> Bool {
        if AXIsProcessTrusted() { return true }
        guard prompt, !didPrompt else { return false }
        didPrompt = true
        let opts = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        AXIsProcessTrustedWithOptions(opts)
        return AXIsProcessTrusted()
    }

    static func frontWindow() -> AXUIElement? {
        guard let app = NSWorkspace.shared.frontmostApplication else { return nil }
        // Skip our own process
        if app.processIdentifier == ProcessInfo.processInfo.processIdentifier { return nil }
        let appEl = AXUIElementCreateApplication(app.processIdentifier)
        var ref: CFTypeRef?
        guard AXUIElementCopyAttributeValue(appEl, kAXFocusedWindowAttribute as CFString, &ref) == .success,
              let ref else { return nil }
        return (ref as! AXUIElement)
    }

    static func frame(_ el: AXUIElement) -> CGRect? {
        var posRef: CFTypeRef?
        var sizeRef: CFTypeRef?
        guard AXUIElementCopyAttributeValue(el, kAXPositionAttribute as CFString, &posRef) == .success,
              AXUIElementCopyAttributeValue(el, kAXSizeAttribute as CFString, &sizeRef) == .success,
              let posRef, let sizeRef else { return nil }
        var pos = CGPoint.zero
        var size = CGSize.zero
        guard AXValueGetValue(posRef as! AXValue, .cgPoint, &pos),
              AXValueGetValue(sizeRef as! AXValue, .cgSize, &size) else { return nil }
        return CGRect(origin: pos, size: size)
    }

    /// AX uses top-left origin; NSScreen uses bottom-left. Flip via primary display height.
    static func cocoaToAX(_ r: CGRect) -> CGRect {
        let h = NSScreen.screens.first?.frame.height ?? 0
        return CGRect(x: r.origin.x, y: h - r.origin.y - r.height, width: r.width, height: r.height)
    }

    static func setFrame(_ el: AXUIElement, _ cocoaRect: CGRect) {
        let r = cocoaToAX(cocoaRect)
        var pos = r.origin
        var size = r.size
        // size → position → size (macOS clamps size to current display first)
        if let v = AXValueCreate(.cgSize, &size) {
            AXUIElementSetAttributeValue(el, kAXSizeAttribute as CFString, v)
        }
        if let v = AXValueCreate(.cgPoint, &pos) {
            AXUIElementSetAttributeValue(el, kAXPositionAttribute as CFString, v)
        }
        if let v = AXValueCreate(.cgSize, &size) {
            AXUIElementSetAttributeValue(el, kAXSizeAttribute as CFString, v)
        }
    }

    static func setMinimized(_ el: AXUIElement, _ minimized: Bool) {
        AXUIElementSetAttributeValue(el, kAXMinimizedAttribute as CFString, minimized ? kCFBooleanTrue : kCFBooleanFalse)
    }

    /// True when frontmost focus is a real text field / editor — pass ⌘←/→ through.
    /// Fast path only: tree walks time out the CGEvent tap → keys leak (Brave back/forward).
    static func isTextInputFocused() -> Bool {
        guard AXIsProcessTrusted(),
              let app = NSWorkspace.shared.frontmostApplication else { return false }
        // Terminals + browsers always snap — sites park focus in sidebars (x.com "Ask Grok", etc.)
        if isTerminalApp(app) || isBrowserApp(app) { return false }
        let appEl = AXUIElementCreateApplication(app.processIdentifier)
        var ref: CFTypeRef?
        guard AXUIElementCopyAttributeValue(appEl, kAXFocusedUIElementAttribute as CFString, &ref) == .success,
              let ref else {
            // No focus info → snap (don't walk; prefer window management over history nav)
            return false
        }
        return isTextInput(ref as! AXUIElement)
    }

    // yagni: static list; add bundle id if another terminal never snaps
    private static let terminalBundleIDs: Set<String> = [
        "dev.warp.Warp-Stable",
        "dev.warp.Warp",
        "com.apple.Terminal",
        "com.googlecode.iterm2",
        "net.kovidgoyal.kitty",
        "com.github.wez.wezterm",
        "io.alacritty",
        "com.mitchellh.ghostty",
    ]

    private static func isTerminalApp(_ app: NSRunningApplication) -> Bool {
        guard let id = app.bundleIdentifier else { return false }
        if terminalBundleIDs.contains(id) { return true }
        return id.hasPrefix("dev.warp.")
    }

    // yagni: static list; add bundle id if another browser never snaps
    private static let browserBundleIDs: Set<String> = [
        "com.brave.Browser",
        "com.brave.Browser.beta",
        "com.brave.Browser.nightly",
        "com.google.Chrome",
        "com.google.Chrome.canary",
        "com.apple.Safari",
        "company.thebrowser.Browser",
        "com.microsoft.edgemac",
        "org.mozilla.firefox",
        "org.mozilla.firefoxdeveloperedition",
        "com.operasoftware.Opera",
        "com.vivaldi.Vivaldi",
        "app.zen-browser.zen",
    ]

    private static func isBrowserApp(_ app: NSRunningApplication) -> Bool {
        guard let id = app.bundleIdentifier else { return false }
        if browserBundleIDs.contains(id) { return true }
        if id.hasPrefix("com.brave.") || id.hasPrefix("com.google.Chrome") { return true }
        return false
    }

    private static let fieldRoles: Set<String> = [
        kAXTextFieldRole as String,
        "AXSearchField",
        "AXSecureTextField",
    ]

    private static func stringAttr(_ el: AXUIElement, _ attr: String) -> String? {
        var ref: CFTypeRef?
        guard AXUIElementCopyAttributeValue(el, attr as CFString, &ref) == .success else { return nil }
        return ref as? String
    }

    private static func hasCaret(_ el: AXUIElement) -> Bool {
        var rangeRef: CFTypeRef?
        return AXUIElementCopyAttributeValue(el, kAXSelectedTextRangeAttribute as CFString, &rangeRef) == .success
            && rangeRef != nil
    }

    private static func valueIsSettable(_ el: AXUIElement) -> Bool {
        var settable = DarwinBoolean(false)
        return AXUIElementIsAttributeSettable(el, kAXValueAttribute as CFString, &settable) == .success
            && settable.boolValue
    }

    private static func isTextInput(_ el: AXUIElement) -> Bool {
        let role = stringAttr(el, kAXRoleAttribute as String)
        // Chromium: page body is focused AXWebArea with a phantom caret — still snap
        if role == "AXWebArea" || role == (kAXScrollAreaRole as String) { return false }

        if let role, fieldRoles.contains(role) { return true }

        let sub = stringAttr(el, kAXSubroleAttribute as String)
        if sub == (kAXSearchFieldSubrole as String) || sub == "AXSecureTextField" { return true }

        var editRef: CFTypeRef?
        if AXUIElementCopyAttributeValue(el, "AXEditable" as CFString, &editRef) == .success,
           let editable = editRef as? Bool, editable {
            return true
        }

        // AXTextArea / combo only when actually editable (Warp canvas is not)
        if role == (kAXTextAreaRole as String) || role == (kAXComboBoxRole as String) {
            return valueIsSettable(el) || hasCaret(el)
        }

        if hasCaret(el),
           role != (kAXStaticTextRole as String),
           role != (kAXButtonRole as String),
           role != (kAXGroupRole as String) {
            return true
        }
        return false
    }
}

// MARK: - Snap

func screenForWindowAXFrame(_ axFrame: CGRect) -> NSScreen {
    // cocoaToAX is an involution — same formula maps AX ↔ Cocoa
    let cocoa = AX.cocoaToAX(axFrame)
    let center = CGPoint(x: cocoa.midX, y: cocoa.midY)
    return NSScreen.screens.first { NSMouseInRect(center, $0.frame, false) } ?? NSScreen.main ?? NSScreen.screens[0]
}

func snap(_ action: SnapAction) {
    guard AX.ensureTrusted() else {
        NSSound.beep()
        return
    }
    guard let win = AX.frontWindow() else {
        NSSound.beep()
        return
    }
    if action == .minimize {
        AX.setMinimized(win, true)
        return
    }
    guard let axFrame = AX.frame(win) else {
        NSSound.beep()
        return
    }
    let screen = screenForWindowAXFrame(axFrame)
    let vf = screen.visibleFrame
    let w = floor(vf.width / 2)
    // fill = all usable space (menu bar / Dock excluded) — not macOS Full Screen
    let rect: CGRect = switch action {
    case .left:     CGRect(x: vf.minX, y: vf.minY, width: w, height: vf.height)
    case .right:    CGRect(x: vf.maxX - w, y: vf.minY, width: w, height: vf.height)
    case .fill:     vf
    case .minimize: preconditionFailure("handled above")
    }
    AX.setFrame(win, rect)
}

// MARK: - Hotkeys (⌘ arrows via CGEvent tap — pass through in text fields)

final class HotKeys {
    private var tap: CFMachPort?
    private var source: CFRunLoopSource?

    /// Global snap hotkeys. Menu items always work.
    var isEnabled: Bool = UserDefaults.standard.object(forKey: "shortcutsEnabled") as? Bool ?? true {
        didSet { UserDefaults.standard.set(isEnabled, forKey: "shortcutsEnabled") }
    }

    func install() {
        let mask = CGEventMask(1 << CGEventType.keyDown.rawValue)
        let refcon = Unmanaged.passUnretained(self).toOpaque()
        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: mask,
            callback: { _, type, event, refcon in
                guard let refcon else { return Unmanaged.passUnretained(event) }
                let hk = Unmanaged<HotKeys>.fromOpaque(refcon).takeUnretainedValue()
                return hk.handle(type: type, event: event)
            },
            userInfo: refcon
        ) else {
            // Needs Accessibility (and sometimes Input Monitoring)
            NSLog("Snap Cat: CGEvent tap failed — grant Accessibility / Input Monitoring")
            return
        }
        self.tap = tap
        let src = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        self.source = src
        CFRunLoopAddSource(CFRunLoopGetMain(), src, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
    }

    private func handle(type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
        if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
            if let tap { CGEvent.tapEnable(tap: tap, enable: true) }
            return Unmanaged.passUnretained(event)
        }
        guard type == .keyDown else { return Unmanaged.passUnretained(event) }
        guard isEnabled else { return Unmanaged.passUnretained(event) }

        let key = event.getIntegerValueField(.keyboardEventKeycode)
        let action: SnapAction? = switch key {
        case Int64(kVK_LeftArrow):  .left
        case Int64(kVK_RightArrow): .right
        case Int64(kVK_UpArrow):    .fill
        case Int64(kVK_DownArrow):  .minimize
        default: nil
        }
        guard let action else { return Unmanaged.passUnretained(event) }

        // Pure ⌘ only (keep ⌘⇧← select-to-line-start, etc.)
        let mods: CGEventFlags = [.maskCommand, .maskShift, .maskAlternate, .maskControl]
        guard event.flags.intersection(mods) == .maskCommand else {
            return Unmanaged.passUnretained(event)
        }

        // Let the app handle line-nav while typing (fast AX only)
        if AX.isTextInputFocused() {
            return Unmanaged.passUnretained(event)
        }

        DispatchQueue.main.async { snap(action) }
        return nil // swallow — prevents Brave history / other defaults
    }
}

// MARK: - App

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let hotKeys = HotKeys()
    private var statusItem: NSStatusItem?
    private var shortcutsMenuItem: NSMenuItem?

    /// Drawn template split-rect (menu bar); app icon stays Snapu.
    private static func statusIcon(side: CGFloat = 16) -> NSImage {
        let img = NSImage(size: NSSize(width: side, height: side), flipped: false) { bounds in
            let r = bounds.insetBy(dx: 1, dy: 1)
            NSColor.black.set()
            let outline = NSBezierPath(roundedRect: r, xRadius: 2, yRadius: 2)
            outline.lineWidth = 1.5
            outline.stroke()
            let mid = NSBezierPath()
            mid.move(to: NSPoint(x: r.midX, y: r.minY + 0.5))
            mid.line(to: NSPoint(x: r.midX, y: r.maxY - 0.5))
            mid.lineWidth = 1.5
            mid.stroke()
            return true
        }
        img.isTemplate = true
        return img
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let btn = item.button {
            btn.image = Self.statusIcon()
            btn.imagePosition = .imageOnly
            btn.imageScaling = .scaleNone
        }
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Snap Left  ⌘←", action: #selector(snapLeft), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Snap Right  ⌘→", action: #selector(snapRight), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Fill Screen  ⌘↑", action: #selector(snapFill), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Minimize  ⌘↓", action: #selector(snapMinimize), keyEquivalent: ""))
        menu.addItem(.separator())
        let shortcuts = NSMenuItem(title: "Keyboard Shortcuts", action: #selector(toggleShortcuts), keyEquivalent: "")
        menu.addItem(shortcuts)
        shortcutsMenuItem = shortcuts
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Accessibility Settings…", action: #selector(openAX), keyEquivalent: ""))
        menu.addItem(.separator())
        let ver = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "?"
        let versionItem = NSMenuItem(title: "Version \(ver)", action: nil, keyEquivalent: "")
        versionItem.isEnabled = false
        menu.addItem(versionItem)
        menu.addItem(NSMenuItem(title: "Quit Snap Cat", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        item.menu = menu
        statusItem = item
        refreshShortcutsUI()

        hotKeys.install()
        _ = AX.ensureTrusted(prompt: true)
    }

    @objc private func snapLeft() { snap(.left) }
    @objc private func snapRight() { snap(.right) }
    @objc private func snapFill() { snap(.fill) }
    @objc private func snapMinimize() { snap(.minimize) }

    @objc private func toggleShortcuts() {
        hotKeys.isEnabled.toggle()
        refreshShortcutsUI()
    }

    private func refreshShortcutsUI() {
        let on = hotKeys.isEnabled
        shortcutsMenuItem?.state = on ? .on : .off
        statusItem?.button?.appearsDisabled = !on
        statusItem?.button?.toolTip = on
            ? "Snap Cat — ⌘← left · ⌘→ right · ⌘↑ fill · ⌘↓ minimize"
            : "Snap Cat — shortcuts off"
    }

    @objc private func openAX() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        }
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
