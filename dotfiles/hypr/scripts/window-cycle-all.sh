#!/usr/bin/env bash
#  __          _______ _   _ _____   ______          ________ _____   _____  _____  _____ _      ______ 
#  \ \        / /_   _| \ | |  __ \ / __ \ \        / / ____/ ____|/ / ____ \____ \|  ___| |    |  ____|
#   \ \  /\  / /  | | |  \| | |  | | |  | \ \  /\  / / |   | |    /  | |    / / _  || |__| |    | |__   
#    \ \/  \/ /   | | | . ` | |  | | |  | |\ \/  \/ /| |   | |   | \  | |   < /   \/|  __| |    |  __|  
#     \  /\  /   _| |_| |\  | |__| | |__| | \  /\  / | |___| |____   | |___<  \____|  |  | |____| |____ 
#      \/  \/   |_____|_| \_|_____/ \____/   \/  \/   \____\_____|   \____/\______|_|  |______|______|
#
# by Tim Sutton (2025) - Window cycling across all workspaces
# ----------------------------------------------------- 

# Window cycle script for Hyprland (all workspaces)
# Cycles through all open windows across all workspaces

# Get all windows across all workspaces
WINDOWS=$(/usr/bin/hyprctl clients -j | /usr/bin/jq -r '.[] | select(.workspace.id != -99) | "\(.address),\(.workspace.id),\(.title),\(.class)"')

if [[ -z "$WINDOWS" ]]; then
    /usr/bin/notify-send "Window Cycle" "No windows found" --urgency=low
    exit 0
fi

# Get currently focused window
CURRENT_WINDOW=$(/usr/bin/hyprctl activewindow -j | /usr/bin/jq -r '.address // empty')

# Convert to array
IFS=$'\n' read -rd '' -a WINDOW_LIST <<< "$WINDOWS"

# Find current window index
CURRENT_INDEX=-1
for i in "${!WINDOW_LIST[@]}"; do
    ADDR=$(echo "${WINDOW_LIST[$i]}" | cut -d',' -f1)
    if [[ "$ADDR" == "$CURRENT_WINDOW" ]]; then
        CURRENT_INDEX=$i
        break
    fi
done

# Calculate next window index (cycle through)
if [[ $CURRENT_INDEX -eq -1 ]]; then
    NEXT_INDEX=0
else
    NEXT_INDEX=$(( (CURRENT_INDEX + 1) % ${#WINDOW_LIST[@]} ))
fi

# Get next window details
NEXT_WINDOW=${WINDOW_LIST[$NEXT_INDEX]}
NEXT_ADDR=$(echo "$NEXT_WINDOW" | cut -d',' -f1)
NEXT_WORKSPACE=$(echo "$NEXT_WINDOW" | cut -d',' -f2)
NEXT_TITLE=$(echo "$NEXT_WINDOW" | cut -d',' -f3)

# Switch to workspace and focus window
/usr/bin/hyprctl dispatch workspace "$NEXT_WORKSPACE"
sleep 0.1
/usr/bin/hyprctl dispatch focuswindow "address:$NEXT_ADDR"

# Optional notification (uncomment to enable)
# /usr/bin/notify-send "Window Focus" "Switched to: $NEXT_TITLE (workspace $NEXT_WORKSPACE)" --urgency=low --expire-time=1000