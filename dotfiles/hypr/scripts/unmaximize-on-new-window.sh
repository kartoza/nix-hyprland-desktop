#!/usr/bin/env bash
# Script to unmaximize/unfullscreen current window when a new window opens
# This ensures new windows are visible instead of hidden behind maximized windows

# Get the active workspace
ACTIVE_WORKSPACE=$(hyprctl activeworkspace -j | jq -r '.id')

# Get all windows on the active workspace that are fullscreen or maximized
# fullscreen can be: 0 (not fullscreen), 1 (maximized), 2 (actual fullscreen)
FULLSCREEN_WINDOWS=$(hyprctl clients -j | jq -r --arg ws "$ACTIVE_WORKSPACE" '.[] | select(.workspace.id == ($ws | tonumber) and .fullscreen != false) | "\(.address)|\(.fullscreen)"')

# If there are any fullscreen/maximized windows, toggle them off
if [ -n "$FULLSCREEN_WINDOWS" ]; then
    echo "$FULLSCREEN_WINDOWS" | while IFS='|' read -r address fullscreen_mode; do
        if [ -n "$address" ]; then
            # Toggle fullscreen off (works for both mode 1 and 2)
            hyprctl dispatch fullscreen 1 address:"$address"
        fi
    done
fi
