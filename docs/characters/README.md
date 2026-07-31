# Snapu

**Snapu** = character · **Snap Cat** = product

Flat **2D vector** packaging kyara (not 3D).

## Official assets

| File | Use |
|------|-----|
| **`snapu.jpg`** | Master art (script on tummy) |
| **`snap-cat.jpg`** | Same master (README) |
| **`snapu-appicon.jpg`** | Cropped + centered square (built from master) |
| **`snapu-centered.jpg`** | Tighter centered marketing square |

## Generated icons (`scripts/build-icons.sh`)

From `snapu.jpg` → crop content, center on square:

| File | Use |
|------|-----|
| `Resources/AppIcon-1024.png` | Master app icon |
| `Resources/AppIcon.icns` | Finder / Accessibility / Dock |
| `Resources/StatusBarIcon.png` (+ `@2x`) | Menu bar (head crop) |
| `Resources/StatusBarIcon-full.png` (+ `@2x`) | Menu bar (full body) |

`./build.sh` runs icon generation automatically.
