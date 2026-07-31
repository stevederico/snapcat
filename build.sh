#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

# Prefer Apple Development so TCC keeps Accessibility across rebuilds
# (ad-hoc CDHash changes every link → macOS treats it as a new app).
SIGN_ID="${HALFSNAP_SIGN_ID:-Apple Development: Stephen Derico (RGS2F76K98)}"
INSTALL_DIR="${HALFSNAP_INSTALL:-/Applications}"

swift build -c release
BIN=".build/release/HalfSnap"
APP="HalfSnap.app"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS"
cp "$BIN" "$APP/Contents/MacOS/HalfSnap"
cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleExecutable</key><string>HalfSnap</string>
  <key>CFBundleIdentifier</key><string>com.stevederico.halfsnap</string>
  <key>CFBundleName</key><string>HalfSnap</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>0.1.0</string>
  <key>CFBundleVersion</key><string>1</string>
  <key>LSMinimumSystemVersion</key><string>13.0</string>
  <key>LSUIElement</key><true/>
  <key>NSHighResolutionCapable</key><true/>
</dict>
</plist>
PLIST

if codesign --force --sign "$SIGN_ID" --identifier com.stevederico.halfsnap "$APP/Contents/MacOS/HalfSnap" \
  && codesign --force --sign "$SIGN_ID" --identifier com.stevederico.halfsnap "$APP"; then
  echo "Signed: $SIGN_ID"
else
  echo "warn: codesign failed, falling back to ad-hoc (Accessibility will break on rebuild)"
  codesign --force --sign - --identifier com.stevederico.halfsnap "$APP"
fi

DEST="$INSTALL_DIR/HalfSnap.app"
rm -rf "$DEST"
cp -R "$APP" "$DEST"
xattr -cr "$DEST" 2>/dev/null || true
echo "Installed $DEST"
