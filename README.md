<div align="center">
  <img src="docs/characters/snapu.jpg" width="220" alt="Snapu">
  <h1 style="border-bottom: none; margin-bottom: 0;">Snap Cat</h1>
  <h3 style="margin-top: 0; font-weight: normal;">
    left / right / fill / minimize for macos — one file, zero bloat
  </h3>
  <p><em>windows that click into place</em> · starring <strong>Snapu</strong></p>
</div>

<br />

**Snap Cat** is the smallest useful window manager for macOS. Four shortcuts. A menu bar icon. Accessibility APIs. No drag-to-snap, no preference window, no updater, no account.

The mascot is **Snapu** — the little window cat who snaps panes into place.

If you want Rectangle with every tile preset — use Rectangle. If you want **⌘ arrows and nothing else** — use this.

<br />

## 🚀 Quick Start

```bash
git clone https://github.com/stevederico/snapcat.git
cd snapcat
./build.sh
open -a SnapCat
```

1. Grant **Accessibility** when prompted (or System Settings → Privacy & Security → Accessibility → enable **Snap Cat**)
2. Quit and reopen Snap Cat once so the grant sticks
3. Press **⌘←** on any window

<br />

## ⌨️ Hotkeys

| Shortcut | Action |
|----------|--------|
| **⌘←** | Left half |
| **⌘→** | Right half |
| **⌘↑** | Fill screen (usable area — menu bar and Dock stay put) |
| **⌘↓** | Minimize |

Not macOS Full Screen. Fill uses the screen's **visible frame** so the window stays a normal windowed app.

<br />

## ✨ What's Included

### 🪟 **Window Actions**
- **Left / right halves** on the display under the window
- **Fill** to all usable space (not Stage Manager / Full Screen theater)
- **Minimize** via Accessibility, same as the yellow button

### 🧠 **Smart Pass-Through**
- **Typing wins** — in a real text field (non-browser apps), ⌘← / ⌘→ stay "line start / line end"
- **Browsers always snap** — Brave, Chrome, Safari, Arc, etc. never pass through (sites park focus in sidebars like x.com Grok)
- **Terminals snap** — Warp, Terminal, iTerm, and friends always get window actions (their UI is one big text view)

### ☰ **Menu Bar App**
- **Status item** with Snap Left / Right / Fill / Minimize
- **Keyboard Shortcuts** checkmark — disable global hotkeys without quitting (persists)
- **Accessibility Settings…** deep link when the grant goes missing
- Menu actions still work when hotkeys are off

### 🪶 **Tiny By Design**
- **One Swift file** — the whole app lives in `Sources/main.swift`
- **No preferences** — hotkeys are fixed; less code, less UI, fewer bugs
- **No network** — no updater, analytics, or phoning home
- **Menu bar only** — `LSUIElement`, no Dock icon

<br />

## 🔧 Requirements

| | |
|--|--|
| **macOS** | 13 Ventura or later |
| **Xcode / CLT** | Swift 5.9+ (`xcode-select --install`) |
| **Permission** | Accessibility for `/Applications/SnapCat.app` |

<br />

## 🏗️ Build & Install

`./build.sh` compiles a release binary, wraps it in `SnapCat.app`, codesigns, and copies to `/Applications`.

```bash
./build.sh
# → /Applications/SnapCat.app
```

**Signing** (Accessibility grants stick better with a stable code signature):

```bash
# Default in this repo: your Apple Development identity (if present)
./build.sh

# Ad-hoc sign (works everywhere; may need re-grant after rebuilds)
SNAPCAT_SIGN_ID="-" ./build.sh

# Custom identity
SNAPCAT_SIGN_ID="Apple Development: Your Name (TEAMID)" ./build.sh
```

Install somewhere else:

```bash
SNAPCAT_INSTALL="$HOME/Applications" ./build.sh
```

If the Accessibility dialog keeps popping up: System Settings → Privacy & Security → Accessibility → remove every **Snap Cat** entry → enable the one from **Applications** → restart Snap Cat.

<br />

## 🛑 Stop

Menu bar icon → **Quit Snap Cat**, or:

```bash
pkill -x SnapCat
```

<br />

## 🧰 Tech Stack

| Technology | Purpose |
|------------|---------|
| **Swift** | App language |
| **Cocoa** | Menu bar status item |
| **ApplicationServices (AX)** | Read/write front window frames, minimize |
| **CGEvent tap** | Global ⌘+arrow hotkeys with pass-through |
| **Carbon.HIToolbox** | Virtual key codes only |

<br />

## 📚 How It Works

1. A **CGEvent tap** watches key-downs for pure ⌘ + arrow (no Shift / Option / Control).
2. If focus is a **real text field**, the key is left alone (line / document navigation).
3. Otherwise Snap Cat **swallows** the event and resizes or minimizes the front window via **Accessibility**.
4. Frames use `NSScreen.visibleFrame` so menu bar and Dock remain visible.

Heavy Accessibility tree walks are intentionally **not** done on the hotkey path — they can timeout the event tap and leak keys (e.g. browser back/forward).

<br />

## 🤝 Contributing

```bash
git clone https://github.com/stevederico/snapcat.git
cd snapcat
./build.sh
open -a SnapCat
```

Keep it small. New tile layouts, prefs panes, and updaters are usually out of scope — open an issue first if you're unsure.

<br />

## 📬 Community & Support

- **🐦 X**: [@stevederico](https://x.com/stevederico)
- **🐛 Issues**: [GitHub Issues](https://github.com/stevederico/snapcat/issues)

<br />

## 🙏 Acknowledgements

- [Rectangle](https://github.com/rxhanson/Rectangle) — the gold standard; Snap Cat is the opposite end of the spectrum
- Apple **Accessibility** and **Quartz Event Services** — the whole app is a thin shell over these

<br />

## 🚀 Ready?

```bash
./build.sh && open -a SnapCat
```

Grant Accessibility. Press ⌘←. Done.

<br />

## 📄 License

MIT License — use it however you want. See [LICENSE](LICENSE) for details.

<br />

---

<div align="center">
  <p>
    Built with ❤️ by <a href="https://github.com/stevederico">Steve Derico</a>
  </p>
  <p>
    <a href="https://github.com/stevederico/snapcat">⭐ Star on GitHub</a> — it helps!
  </p>
</div>
