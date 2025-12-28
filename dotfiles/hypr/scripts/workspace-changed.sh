#!/usr/bin/env bash
# Hyprland workspace change trigger script
# Called whenever a workspace is changed

# Get current workspace information
# First try to get from command line argument (preferred)
if [[ -n "$1" ]]; then
    CURRENT_WS="$1"
else
    # Fall back to reading from cache file
    if [[ -f "$HOME/.cache/hyprland-current-workspace" ]]; then
        CURRENT_WS=$(cat "$HOME/.cache/hyprland-current-workspace" 2>/dev/null | tr -d '\n')
    else
        CURRENT_WS="0"
    fi
fi

WS_NAME_FILE="$HOME/.config/hypr/workspace-names.conf"
SYSTEM_WORKSPACE_NAMES_FILE="/etc/xdg/hypr/workspace-names.conf"

# Ensure user config directory exists
mkdir -p "$(dirname "$WS_NAME_FILE")"

# Copy system default if user config doesn't exist
if [[ ! -f "$WS_NAME_FILE" && -f "$SYSTEM_WORKSPACE_NAMES_FILE" ]]; then
    cp "$SYSTEM_WORKSPACE_NAMES_FILE" "$WS_NAME_FILE"
fi

WS_NAME=$(cat "$WS_NAME_FILE" 2>/dev/null | grep "^${CURRENT_WS}=" | cut -d'=' -f2 || echo "Workspace ${CURRENT_WS}")

# Log the workspace change
echo "$(date '+%Y-%m-%d %H:%M:%S') - Changed to workspace: ${CURRENT_WS} (${WS_NAME})" >> ~/.local/state/hyprland-workspace.log

# Create log directory if it doesn't exist
mkdir -p ~/.local/state

# Show workspace overlay with eww (slides in from right, docked to edge)
if command -v workspace-overlay.sh >/dev/null 2>&1; then
    workspace-overlay.sh "$((CURRENT_WS + 1))" "${WS_NAME}" &
fi

# You can add more custom actions here:
# - Update workspace-specific configs
# - Start/stop workspace-specific services
# - Change wallpaper per workspace
# - etc.

exit 0