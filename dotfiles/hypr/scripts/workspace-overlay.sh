#!/usr/bin/env bash
# Show workspace overlay using eww
# Usage: workspace-overlay.sh <workspace_number> <workspace_name>

WORKSPACE_NUMBER="${1:-0}"
WORKSPACE_NAME="${2:-Workspace}"
DISPLAY_DURATION="${3:-2000}" # milliseconds to show overlay (2 seconds)

# Ensure eww is running
if ! pgrep -x eww > /dev/null; then
    eww daemon &
    sleep 0.5
fi

# Open the overlay window if not already open
if ! eww windows | grep -q "workspace-overlay"; then
    eww open workspace-overlay 2>/dev/null || true
fi

# Update workspace information
eww update workspace_number="$WORKSPACE_NUMBER"
eww update workspace_name="$WORKSPACE_NAME"

# Show the overlay with animation
eww update workspace_visible=true

# Hide after duration (in background)
(
    sleep $(echo "scale=2; $DISPLAY_DURATION / 1000" | bc)
    eww update workspace_visible=false

    # Close the window after animation completes (add animation duration)
    sleep 0.5
    eww close workspace-overlay 2>/dev/null || true
) &

exit 0
