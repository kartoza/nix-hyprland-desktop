#!/usr/bin/env bash
# Test script for pinentry and security dialog window rules
# This script helps verify that pinentry dialogs appear correctly
# with blur, dimming, and above fullscreen windows

echo "=== Testing Pinentry and Security Dialogs ==="
echo ""
echo "This script will help you test the security dialog window rules."
echo ""

# Check if GPG is available
if ! command -v gpg &> /dev/null; then
    echo "Error: GPG is not installed."
    exit 1
fi

echo "1. Testing GPG pinentry dialog..."
echo "   This will prompt for a passphrase using pinentry."
echo "   The dialog should:"
echo "   - Float in the center"
echo "   - Blur and dim the background"
echo "   - Stay on top even if you switch workspaces"
echo "   - Interrupt fullscreen windows"
echo ""
echo "   Press Enter to continue or Ctrl+C to cancel..."
read

# Create a temporary test file
TESTFILE=$(mktemp)
echo "Test content for GPG signing" > "$TESTFILE"

echo "Creating a test GPG signature (you may need to enter your passphrase)..."
gpg --sign "$TESTFILE"

if [ $? -eq 0 ]; then
    echo "✓ Success! The pinentry dialog should have appeared."
    echo "  Did it blur/dim the background?"
    echo "  Was it centered and floating?"
    echo "  Did it stay focused?"
    rm -f "$TESTFILE" "$TESTFILE.gpg"
else
    echo "✗ GPG signing failed or was cancelled"
    rm -f "$TESTFILE"
fi

echo ""
echo "2. To test with a fullscreen window:"
echo "   - Open a fullscreen application (Super+F)"
echo "   - Run this script again"
echo "   - The pinentry should interrupt the fullscreen"
echo ""
echo "3. To test zenity dialogs:"
echo "   zenity --password --title='Test Password Dialog'"
echo ""
echo "4. To verify window rules are active:"
echo "   hyprctl clients | grep -A 10 'gcr-prompter\\|pinentry\\|zenity'"
echo ""
