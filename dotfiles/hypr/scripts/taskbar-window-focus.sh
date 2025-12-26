#!/usr/bin/env bash
#  _______        _____ _  __ ____          _____    ______      _____ _    _  _____ 
# |__   __|  /\  / ____| |/ /|  _ \   /\   |  __ \  |  ____|    |  ___| |  | |/ ____|
#    | |    /  \| (___ | ' / | |_) | /  \  | |__) | | |__   --> |  ___| |  | | |     
#    | |   / /\ \\___ \|  <  |  _ < / /\ \ |  _  /  |  __|     |  ___| |  | | |     
#    | |  / ____ \___) | . \ | |_) / ____ \| | \ \  | |        |  ___| |__| | |____ 
#    |_| /_/    \_\____/|_|\_\|____/_/    \_\_|  \_\ |_|        |_____|\____/ \_____|
#
# by Tim Sutton (2025) - Enhanced taskbar window management
# ----------------------------------------------------- 

# Taskbar window focus script for Hyprland
# Switches to workspace, raises window, and focuses it when clicking taskbar icon

# Check if window address argument is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <window_address>"
    echo "Example: $0 0x123456789abcdef0"
    exit 1
fi

WINDOW_ADDRESS="$1"

# Get window information from hyprctl
WINDOW_INFO=$(/usr/bin/hyprctl clients -j | /usr/bin/jq -r ".[] | select(.address == \"$WINDOW_ADDRESS\")")

if [ -z "$WINDOW_INFO" ] || [ "$WINDOW_INFO" == "null" ]; then
    echo "Window with address $WINDOW_ADDRESS not found"
    exit 1
fi

# Extract workspace ID where the window is located
WORKSPACE_ID=$(echo "$WINDOW_INFO" | /usr/bin/jq -r '.workspace.id')

if [ "$WORKSPACE_ID" == "null" ] || [ -z "$WORKSPACE_ID" ]; then
    echo "Could not determine workspace for window $WINDOW_ADDRESS"
    exit 1
fi

# Get current workspace to check if we need to switch
CURRENT_WORKSPACE=$(/usr/bin/hyprctl activeworkspace -j | /usr/bin/jq -r '.id')

# Switch to the window's workspace if not already there
if [ "$WORKSPACE_ID" != "$CURRENT_WORKSPACE" ]; then
    /usr/bin/hyprctl dispatch workspace "$WORKSPACE_ID"
    # Small delay to ensure workspace switch completes
    sleep 0.1
fi

# Bring window to top (raise it above other windows)
/usr/bin/hyprctl dispatch bringactivetotop "address:$WINDOW_ADDRESS"

# Focus the window
/usr/bin/hyprctl dispatch focuswindow "address:$WINDOW_ADDRESS"

# Optional: Notify about the action (comment out if too verbose)
# WINDOW_TITLE=$(echo "$WINDOW_INFO" | jq -r '.title // .class')
# notify-send "Window Focus" "Switched to workspace $WORKSPACE_ID and focused: $WINDOW_TITLE" --urgency=low --expire-time=1000