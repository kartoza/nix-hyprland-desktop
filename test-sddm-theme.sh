#!/usr/bin/env bash
# Test SDDM theme without rebooting
# This script checks the QML theme for errors and runs it in test mode

THEME_DIR_SYSTEM="/etc/sddm/themes/kartoza"
THEME_DIR_DEV="/home/timlinux/dev/nix/nix-hyprland-desktop/dotfiles/sddm/themes/kartoza"
QML_FILE_SYSTEM="$THEME_DIR_SYSTEM/Main.qml"
QML_FILE_DEV="$THEME_DIR_DEV/Main.qml"

echo "=== SDDM Theme Testing Script ==="
echo ""

# Check if development theme exists
if [[ ! -f "$QML_FILE_DEV" ]]; then
    echo "❌ Development theme not found at: $QML_FILE_DEV"
    exit 1
fi
echo "✅ Development theme found at: $QML_FILE_DEV"

# Check if system theme exists
if [[ -f "$QML_FILE_SYSTEM" ]]; then
    echo "✅ System theme found at: $QML_FILE_SYSTEM"
else
    echo "⚠️  System theme not found (run 'sudo nixos-rebuild switch' to install)"
fi
echo ""

# Check if sddm-greeter exists
echo "--- Checking SDDM Greeter ---"
if command -v sddm-greeter &>/dev/null; then
    echo "✅ sddm-greeter found: $(which sddm-greeter)"
elif command -v sddm-greeter-qt6 &>/dev/null; then
    echo "⚠️  Only sddm-greeter-qt6 found: $(which sddm-greeter-qt6)"
    echo "   Theme may look for 'sddm-greeter'"
else
    echo "❌ No SDDM greeter found!"
    exit 1
fi
echo ""

# Try to parse QML for syntax errors using qmlscene
echo "--- Testing QML Syntax ---"
if command -v qmlscene &>/dev/null; then
    echo "Using qmlscene to check QML..."

    # Set QML import path
    export QML2_IMPORT_PATH="/run/current-system/sw/lib/qt-6/qml:$QML2_IMPORT_PATH"

    timeout 3 qmlscene "$QML_FILE_DEV" 2>&1 | head -20 || true
    echo ""
else
    echo "⚠️  qmlscene not available, skipping syntax check"
fi
echo ""

# Show current SDDM logs if system theme is installed
if [[ -f "$QML_FILE_SYSTEM" ]]; then
    echo "--- Current SDDM Theme Status ---"
    if journalctl -u display-manager -b --no-pager 2>/dev/null | grep -i "theme" | tail -5 | grep -q .; then
        journalctl -u display-manager -b --no-pager | grep -i "theme" | tail -5
    else
        echo "No recent SDDM theme messages in journal"
    fi
    echo ""
fi

echo "==================================="
echo "Launching SDDM greeter in test mode..."
echo "Theme path: $THEME_DIR_DEV"
echo ""
echo "Note: This is a non-functional preview."
echo "Login won't work in test mode."
echo "Press Ctrl+C or close the window to exit."
echo "==================================="
echo ""

sddm-greeter --test-mode --theme "$THEME_DIR_DEV"
