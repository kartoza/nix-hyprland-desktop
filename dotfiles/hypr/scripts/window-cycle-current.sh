#!/usr/bin/env bash
#  __          _______ _   _ _____   ______          ____  _    _ _____  _____  ______ _   _ _______ 
#  \ \        / /_   _| \ | |  __ \ / __ \ \        / / ____| |  | |  __ \|  __ \|  ____| \ | |__   __|
#   \ \  /\  / /  | | |  \| | |  | | |  | \ \  /\  / / |    | |  | | |__) | |__) | |__  |  \| |  | |   
#    \ \/  \/ /   | | | . ` | |  | | |  | |\ \/  \/ /| |    | |  | |  _  /|  _  /|  __| | . ` |  | |   
#     \  /\  /   _| |_| |\  | |__| | |__| | \  /\  / | |____| |__| | | \ \| | \ \| |____| |\  |  | |   
#      \/  \/   |_____|_| \_|_____/ \____/   \/  \/   \____|\____/|_|  \_\_|  \_\______|_| \_|  |_|   
#
# by Tim Sutton (2025) - Window cycling in current workspace
# ----------------------------------------------------- 

# Window cycle script for Hyprland (current workspace only)
# Cycles through windows in the current workspace

# Get current workspace
CURRENT_WORKSPACE=$(/usr/bin/hyprctl activeworkspace -j | /usr/bin/jq -r '.id')

# Get windows in current workspace only
WINDOWS=$(/usr/bin/hyprctl clients -j | /usr/bin/jq -r ".[] | select(.workspace.id == $CURRENT_WORKSPACE) | \"\(.address),\(.title),\(.class)\"")

if [[ -z "$WINDOWS" ]]; then
    /usr/bin/notify-send "Window Cycle" "No windows in current workspace" --urgency=low
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
NEXT_TITLE=$(echo "$NEXT_WINDOW" | cut -d',' -f2)

# Focus window (no workspace switching needed)
/usr/bin/hyprctl dispatch focuswindow "address:$NEXT_ADDR"

# Optional notification (uncomment to enable)
# /usr/bin/notify-send "Window Focus" "Focused: $NEXT_TITLE" --urgency=low --expire-time=1000