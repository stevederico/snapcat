import Cocoa
import ApplicationServices
import Carbon.HIToolbox

// HalfSnap — left/right window halves via Accessibility (Rectangle's core, ~nothing else)

enum Side { case left, right }

// MARK: - AX

enum AX {
    static func ensureTrusted() -> Bool {
        if AXIsProcessTrusted() { return true }
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
}

// MARK: - Snap

func screenForWindowAXFrame(_ axFrame: CGRect) -> NSScreen {
    // cocoaToAX is an involution — same formula maps AX ↔ Cocoa
    let cocoa = AX.cocoaToAX(axFrame)
    let center = CGPoint(x: cocoa.midX, y: cocoa.midY)
    return NSScreen.screens.first { NSMouseInRect(center, $0.frame, false) } ?? NSScreen.main ?? NSScreen.screens[0]
}

func snap(_ side: Side) {
    guard AX.ensureTrusted() else {
        NSSound.beep()
        return
    }
    guard let win = AX.frontWindow(), let axFrame = AX.frame(win) else {
        NSSound.beep()
        return
    }
    let screen = screenForWindowAXFrame(axFrame)
    let vf = screen.visibleFrame
    let w = floor(vf.width / 2)
    let rect: CGRect = switch side {
    case .left:  CGRect(x: vf.minX, y: vf.minY, width: w, height: vf.height)
    case .right: CGRect(x: vf.maxX - w, y: vf.minY, width: w, height: vf.height)
    }
    AX.setFrame(win, rect)
}

// MARK: - Hotkeys (⌥← / ⌥→)

final class HotKeys {
    private var leftRef: EventHotKeyRef?
    private var rightRef: EventHotKeyRef?
    private var handler: EventHandlerRef?

    func install() {
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        let status = InstallEventHandler(GetApplicationEventTarget(), { (_, event, _) -> OSStatus in
            var hk = EventHotKeyID()
            GetEventParameter(event, EventParamName(kEventParamDirectObject), EventParamType(typeEventHotKeyID),
                              nil, MemoryLayout<EventHotKeyID>.size, nil, &hk)
            if hk.id == 1 { snap(.left) }
            else if hk.id == 2 { snap(.right) }
            return noErr
        }, 1, &eventType, nil, &handler)
        guard status == noErr else { return }

        let mods = UInt32(optionKey)
        let leftID = EventHotKeyID(signature: OSType(0x48414C46), id: 1) // 'HALF'
        let rightID = EventHotKeyID(signature: OSType(0x48414C46), id: 2)
        RegisterEventHotKey(UInt32(kVK_LeftArrow), mods, leftID, GetApplicationEventTarget(), 0, &leftRef)
        RegisterEventHotKey(UInt32(kVK_RightArrow), mods, rightID, GetApplicationEventTarget(), 0, &rightRef)
    }
}

// MARK: - App

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let hotKeys = HotKeys()
    private var statusItem: NSStatusItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let btn = item.button {
            btn.title = "◫"
            btn.toolTip = "HalfSnap — ⌥← left · ⌥→ right"
        }
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Snap Left  ⌥←", action: #selector(snapLeft), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Snap Right  ⌥→", action: #selector(snapRight), keyEquivalent: ""))
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Accessibility Settings…", action: #selector(openAX), keyEquivalent: ""))
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Quit HalfSnap", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        item.menu = menu
        statusItem = item

        hotKeys.install()
        _ = AX.ensureTrusted()
    }

    @objc private func snapLeft() { snap(.left) }
    @objc private func snapRight() { snap(.right) }

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
