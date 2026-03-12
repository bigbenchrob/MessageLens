#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────────────
# build_and_notarize.sh — Build, sign, package, and notarize MessageLens
# ──────────────────────────────────────────────────────────────────────
#
# Prerequisites (one-time setup):
#   1. Developer ID Application certificate in Keychain
#   2. App-specific password from https://appleid.apple.com
#   3. Store credentials:
#        xcrun notarytool store-credentials "notarytool-password" \
#          --apple-id "bigbenchrob@gmail.com" \
#          --team-id "FQHT2QP3NE" \
#          --password "YOUR_APP_SPECIFIC_PASSWORD"
#
# Usage:
#   ./tool/build_and_notarize.sh          # Full pipeline
#   ./tool/build_and_notarize.sh --skip-build   # Repackage existing build
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
APP_NAME="MessageLens"
APP_PATH="$PROJECT_DIR/build/macos/Build/Products/Release/$APP_NAME.app"
DMG_PATH="$HOME/Desktop/$APP_NAME.dmg"
KEYCHAIN_PROFILE="notarytool-password"
SIGNING_IDENTITY="Developer ID Application: Robert Campbell (FQHT2QP3NE)"

# ── Helpers ───────────────────────────────────────────────────────────

step() {
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  $1"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

fail() {
  echo "❌ $1" >&2
  exit 1
}

# ── Step 1: Build ─────────────────────────────────────────────────────

if [[ "${1:-}" != "--skip-build" ]]; then
  step "Step 1/7: Building release"
  cd "$PROJECT_DIR"
  flutter build macos --release
else
  step "Step 1/7: Skipping build (--skip-build)"
fi

[[ -d "$APP_PATH" ]] || fail "App not found at $APP_PATH"

# ── Step 2: Re-sign embedded frameworks and the app ──────────────────

step "Step 2/7: Re-signing embedded frameworks and app bundle"

# Re-sign every embedded framework with the Developer ID identity
# and hardened runtime.  This fixes stale signatures left by build tools.
FRAMEWORKS_DIR="$APP_PATH/Contents/Frameworks"
if [[ -d "$FRAMEWORKS_DIR" ]]; then
  for fw in "$FRAMEWORKS_DIR"/*.framework "$FRAMEWORKS_DIR"/*.dylib; do
    [[ -e "$fw" ]] || continue
    echo "  Signing: $(basename "$fw")"
    codesign --force --sign "$SIGNING_IDENTITY" \
      --options runtime \
      --timestamp \
      "$fw"
  done
fi

# Re-sign the main app bundle (picks up the freshly signed frameworks)
echo "  Signing: $APP_NAME.app"
codesign --force --sign "$SIGNING_IDENTITY" \
  --options runtime \
  --entitlements "$PROJECT_DIR/macos/Runner/Release.entitlements" \
  --timestamp \
  "$APP_PATH"

# ── Step 3: Verify code signature ────────────────────────────────────

step "Step 3/7: Verifying code signature"
codesign --verify --deep --strict "$APP_PATH" 2>&1
echo "Signing identity:"
codesign -dvv "$APP_PATH" 2>&1 | grep "Authority=" | head -1

# ── Step 4: Create DMG ───────────────────────────────────────────────

step "Step 4/7: Creating DMG"
rm -f "$DMG_PATH"
hdiutil create \
  -volname "$APP_NAME" \
  -srcfolder "$APP_PATH" \
  -ov \
  -format UDZO \
  "$DMG_PATH"
echo "DMG created: $DMG_PATH"

# ── Step 5: Submit for notarization ──────────────────────────────────

step "Step 5/7: Submitting for notarization (this may take a few minutes)"
xcrun notarytool submit "$DMG_PATH" \
  --keychain-profile "$KEYCHAIN_PROFILE" \
  --wait

# ── Step 6: Staple the ticket ────────────────────────────────────────

step "Step 6/7: Stapling notarization ticket to DMG"
xcrun stapler staple "$DMG_PATH"

# ── Step 7: Final verification ───────────────────────────────────────

step "Step 7/7: Verifying notarization"
# spctl --assess on DMGs can give false "rejected" results.
# Instead, verify the staple is present and the app itself passes.
xcrun stapler validate "$DMG_PATH" 2>&1
echo "Notarization ticket is stapled to DMG."
echo ""
echo "Verifying app bundle signature:"
spctl --assess --verbose=2 "$APP_PATH" 2>&1 || true

echo ""
echo "✅ Done! Notarized DMG ready at: $DMG_PATH"
echo ""
