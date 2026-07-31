#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

# Prefer Apple Development so TCC keeps Accessibility across rebuilds
# (ad-hoc CDHash changes every link → macOS treats it as a new app).
SIGN_ID="${SNAPCAT_SIGN_ID:-${HALFSNAP_SIGN_ID:-Apple Development: Stephen Derico (RGS2F76K98)}}"
INSTALL_DIR="${SNAPCAT_INSTALL:-${HALFSNAP_INSTALL:-/Applications}}"
BUNDLE_ID="com.stevederico.snapcat"

swift build -c release
BIN=".build/release/SnapCat"
APP="SnapCat.app"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS"
cp "$BIN" "$APP/Contents/MacOS/SnapCat"
cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleExecutable</key><string>SnapCat</string>
  <key>CFBundleIdentifier</key><string>${BUNDLE_ID}</string>
  <key>CFBundleName</key><string>Snap Cat</string>
  <key>CFBundleDisplayName</key><string>Snap Cat</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>2.0.1</string>
  <key>CFBundleVersion</key><string>21</string>
  <key>LSMinimumSystemVersion</key><string>13.0</string>
  <key>LSUIElement</key><true/>
  <key>NSHighResolutionCapable</key><true/>
</dict>
</plist>
PLIST

if codesign --force --sign "$SIGN_ID" --identifier "$BUNDLE_ID" "$APP/Contents/MacOS/SnapCat" \
  && codesign --force --sign "$SIGN_ID" --identifier "$BUNDLE_ID" "$APP"; then
  echo "Signed: $SIGN_ID"
else
  echo "warn: codesign failed, falling back to ad-hoc (Accessibility will break on rebuild)"
  codesign --force --sign - --identifier "$BUNDLE_ID" "$APP"
fi

DEST="$INSTALL_DIR/SnapCat.app"
rm -rf "$DEST"
# Remove old HalfSnap install if present (same machine)
rm -rf "$INSTALL_DIR/HalfSnap.app" 2>/dev/null || true
cp -R "$APP" "$DEST"
xattr -cr "$DEST" 2>/dev/null || true
echo "Installed $DEST"
