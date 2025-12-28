#!/usr/bin/env bash
# Fuzzel-based workspace switcher for Hyprland

WORKSPACE_NAMES_FILE="$HOME/.config/hypr/workspace-names.conf"
SYSTEM_WORKSPACE_NAMES_FILE="/etc/xdg/hypr/workspace-names.conf"

# Ensure we have a workspace names file
if [[ ! -f "$WORKSPACE_NAMES_FILE" ]]; then
    if [[ -f "$SYSTEM_WORKSPACE_NAMES_FILE" ]]; then
        mkdir -p "$(dirname "$WORKSPACE_NAMES_FILE")"
        cp "$SYSTEM_WORKSPACE_NAMES_FILE" "$WORKSPACE_NAMES_FILE"
    fi
fi

# Function to get current workspace using workspace manager
get_current_workspace() {
    # Use hyprland workspace manager for reliable workspace detection
    if [[ -x "$(command -v hyprland-workspace-manager.sh)" ]]; then
        hyprland-workspace-manager.sh get
    else
        # Fallback to cache file reading
        local state_file="$HOME/.cache/hyprland-current-workspace"
        if [[ -f "$state_file" ]]; then
            local workspace=$(cat "$state_file" 2>/dev/null | tr -d '\n')
            if [[ "$workspace" =~ ^[0-8]$ ]]; then
                echo "$workspace"
                return
            fi
        fi
        
        # Default to workspace 0 if all methods fail
        echo "0"
    fi
}

# Function to get workspace name
get_workspace_name() {
    local ws_num="$1"
    if [[ -f "$WORKSPACE_NAMES_FILE" ]]; then
        local name=$(grep "^${ws_num}=" "$WORKSPACE_NAMES_FILE" | cut -d'=' -f2 | head -1)
        echo "${name:-"Workspace $ws_num"}"
    else
        echo "Workspace $ws_num"
    fi
}

# Function to switch to workspace
switch_to_workspace() {
    local ws_num="$1"
    if [[ "$ws_num" =~ ^[0-8]$ ]]; then
        # Use hyprctl to switch workspaces directly (workspaces 1-9 in Hyprland)
        local hypr_ws=$((ws_num + 1))
        hyprctl dispatch workspace "$hypr_ws" >/dev/null 2>&1

        # Update our state cache
        mkdir -p "$HOME/.cache"
        echo "$ws_num" > "$HOME/.cache/hyprland-current-workspace"

        # Call workspace changed hook
        if [[ -x "$(command -v workspace-changed.sh)" ]]; then
            workspace-changed.sh "$ws_num" &
        fi
    fi
}

# Generate workspace list for fuzzel
generate_workspace_list() {
    local current_ws=$(get_current_workspace)
    
    for ws_num in {0..8}; do
        local ws_name=$(get_workspace_name "$ws_num")
        local indicator=""
        
        # Add indicator for current workspace
        if [[ "$ws_num" == "$current_ws" ]]; then
            indicator=" 󰄴"  # Current workspace indicator
        fi
        
        # Format: "workspace_number: workspace_name [current_indicator]"
        echo "${ws_num}: ${ws_name}${indicator}"
    done
}

# Main logic
if command -v fuzzel >/dev/null 2>&1; then
    # Generate options and show fuzzel with Kartoza styling
    selected=$(generate_workspace_list | fuzzel --dmenu \
        --prompt="Kartoza Workspace: " \
        --width=48 \
        --lines=9 \
        --font="JetBrains Mono:size=12" \
        --background-color=1a110fdd \
        --text-color=f1dfdaff \
        --match-color=ffb59dff \
        --selection-color=723520ff \
        --selection-text-color=ffdbd0ff \
        --border-color=ffb59dff \
        --border-width=2)
    
    if [[ -n "$selected" ]]; then
        # Extract workspace number from selection
        ws_num=$(echo "$selected" | cut -d':' -f1)
        switch_to_workspace "$ws_num"
    fi
else
    echo "Error: fuzzel not found" >&2
    notify-send "Workspace Switcher" "fuzzel not installed" -i dialog-error
    exit 1
fi