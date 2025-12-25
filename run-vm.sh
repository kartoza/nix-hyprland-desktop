#!/usr/bin/env bash
# Convenience script for running the Hyprland Desktop test VM

set -euo pipefail

echo "🚀 Building and running Kartoza Hyprland Desktop test VM..."
echo "   - VM will have 4GB RAM, 4 CPU cores, 8GB disk"
echo "   - Auto-login as 'testuser' with password 'test'"
echo "   - Resolution: 1920x1080 with hardware acceleration"
echo "   - Floating windows by default, working taskbar"
echo ""

# Build and run the VM
nix run .#nixosConfigurations.vm-test.config.system.build.vm

echo ""
echo "✅ VM session completed!"