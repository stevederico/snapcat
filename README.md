# HalfSnap

Left / right window halves. Accessibility only. No drag-snap, no prefs, no updater.

## Hotkeys

| Shortcut | Action |
|----------|--------|
| `⌘←` | Left half |
| `⌘→` | Right half |

Disabled while a text field / editor is focused (line start/end still works). Terminals (Warp, etc.) always snap — their UI is one big text view.

## Run

```bash
./build.sh          # builds + installs to /Applications/HalfSnap.app
open -a HalfSnap
```

Grant **Accessibility** once for `/Applications/HalfSnap.app`, then quit and reopen HalfSnap.

If the permission dialog keeps popping up: System Settings → Privacy & Security → Accessibility → remove every HalfSnap entry → re-enable the one from **Applications** → restart HalfSnap. (Ad-hoc rebuilds used to break this; builds are now signed with Apple Development so the grant sticks.)

## Stop

Menu bar `◫` → Quit HalfSnap, or `pkill -x HalfSnap`.
