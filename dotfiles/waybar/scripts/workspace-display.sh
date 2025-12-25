#!/usr/bin/env bash
# Waybar workspace display widget for Hyprland
# Shows current workspace number and name

WORKSPACE_NAMES_FILE="$(xdg-config-path hypr/workspace-names.conf 2>/dev/null || echo "$HOME/.config/hypr/workspace-names.conf")"

# Function to get current workspace
get_current_workspace() {
    # Use hyprctl to get current workspace
    local current_workspace=$(hyprctl activeworkspace -j 2>/dev/null | jq -r '.id')
    
    # Convert to 0-based indexing (Hyprland uses 1-based)
    if [[ "$current_workspace" =~ ^[1-9]$ ]]; then
        echo $((current_workspace - 1))
    else
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

# Get current workspace info
current_ws=$(get_current_workspace)
ws_name=$(get_workspace_name "$current_ws")

# Generate waybar JSON output
echo "{\"text\": \"$((current_ws + 1)): ${ws_name}\", \"tooltip\": \"Current workspace: $((current_ws + 1)) (${ws_name})\\nClick to switch workspaces\", \"class\": \"workspace-${current_ws}\"}"