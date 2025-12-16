#!/usr/bin/env bash

# Waybar keyboard layout toggle script
# Toggles between US and European Portuguese layouts

# Define layouts
LAYOUT_US="us"
LAYOUT_PT="pt"

# State file to track current layout
STATE_FILE="$HOME/.local/state/keyboard-layout"
mkdir -p "$(dirname "$STATE_FILE")"

# Initialize state file if it doesn't exist
if [[ ! -f "$STATE_FILE" ]]; then
    echo "$LAYOUT_US" > "$STATE_FILE"
fi

# Get current layout from state file
get_current_layout() {
    cat "$STATE_FILE" 2>/dev/null || echo "$LAYOUT_US"
}

# Set layout using available tools
set_layout() {
    local layout="$1"
    
    # Try different methods to set keyboard layout
    if command -v setxkbmap >/dev/null 2>&1; then
        setxkbmap "$layout"
    elif command -v localectl >/dev/null 2>&1; then
        localectl set-x11-keymap "$layout"
    fi
    
    # Update state file
    echo "$layout" > "$STATE_FILE"
}

# Toggle layout
toggle_layout() {
    current=$(get_current_layout)
    if [[ "$current" == "$LAYOUT_US" ]]; then
        set_layout "$LAYOUT_PT"
        echo "PT"
    else
        set_layout "$LAYOUT_US"
        echo "EN"
    fi
}

# Display current layout for waybar
display_layout() {
    current=$(get_current_layout)
    if [[ "$current" == "$LAYOUT_PT" ]]; then
        echo "PT"
    else
        echo "EN"
    fi
}

case "${1}" in
    toggle)
        toggle_layout
        ;;
    *)
        display_layout
        ;;
esac