#!/usr/bin/env bash
# Wayfire workspace management utility
# Provides reliable workspace switching and state tracking for Wayfire

CACHE_FILE="$HOME/.cache/wayfire-current-workspace"
WORKSPACE_NAMES_FILE="$(xdg-config-path wayfire/workspace-names.conf 2>/dev/null || echo "$HOME/.config/wayfire/workspace-names.conf")"

# Ensure cache directory exists
mkdir -p "$(dirname "$CACHE_FILE")"

# Initialize cache with workspace 0 if it doesn't exist
if [[ ! -f "$CACHE_FILE" ]]; then
    echo "0" > "$CACHE_FILE"
fi

# Function to get current workspace
get_workspace() {
    if [[ -f "$CACHE_FILE" ]]; then
        local workspace=$(cat "$CACHE_FILE" 2>/dev/null | tr -d '\n')
        if [[ "$workspace" =~ ^[0-8]$ ]]; then
            echo "$workspace"
            return
        fi
    fi
    
    # Default to 0 if cache is invalid
    echo "0"
    echo "0" > "$CACHE_FILE"
}

# Function to set workspace
set_workspace() {
    local workspace="$1"
    
    if [[ ! "$workspace" =~ ^[0-8]$ ]]; then
        echo "Error: Invalid workspace number. Must be 0-8" >&2
        return 1
    fi
    
    # Update cache
    echo "$workspace" > "$CACHE_FILE"
    
    # Switch to workspace using wayfire vswitch plugin
    # Map workspace 0-8 to keys 1-9
    local key_num=$((workspace + 1))
    
    # Use wtype to send Super+Number key combination
    if command -v wtype >/dev/null 2>&1; then
        wtype -M logo -k "$key_num" -m logo
    else
        echo "Warning: wtype not found, cannot switch workspace" >&2
        return 1
    fi
    
    # Call workspace changed hook if available
    if [[ -x "$(command -v workspace-changed.sh)" ]]; then
        workspace-changed.sh "$workspace" &
    fi
    
    return 0
}

# Function to get workspace name
get_workspace_name() {
    local ws_num="${1:-$(get_workspace)}"
    
    if [[ -f "$WORKSPACE_NAMES_FILE" ]]; then
        local name=$(grep "^${ws_num}=" "$WORKSPACE_NAMES_FILE" | cut -d'=' -f2 | head -1)
        echo "${name:-"Workspace $ws_num"}"
    else
        echo "Workspace $ws_num"
    fi
}

# Main command handling
case "${1:-}" in
    "get"|"current")
        get_workspace
        ;;
    "set"|"switch")
        if [[ -z "$2" ]]; then
            echo "Usage: $0 set <workspace_number>"
            exit 1
        fi
        set_workspace "$2"
        ;;
    "name")
        get_workspace_name "$2"
        ;;
    "info")
        current=$(get_workspace)
        name=$(get_workspace_name "$current")
        echo "Current workspace: $current"
        echo "Workspace name: $name"
        echo "Display: $((current + 1)): $name"
        ;;
    "init")
        # Initialize workspace tracking
        echo "Initializing workspace tracking..."
        echo "0" > "$CACHE_FILE"
        echo "Workspace tracking initialized with workspace 0"
        ;;
    *)
        echo "Wayfire Workspace Manager"
        echo "Usage: $0 {get|set|name|info|init} [args...]"
        echo ""
        echo "Commands:"
        echo "  get|current              - Get current workspace number"
        echo "  set|switch <number>      - Switch to workspace number (0-8)"
        echo "  name [number]            - Get workspace name (current if no number)"
        echo "  info                     - Show current workspace info"
        echo "  init                     - Initialize workspace tracking"
        echo ""
        echo "Examples:"
        echo "  $0 get                   # Get current workspace"
        echo "  $0 set 2                 # Switch to workspace 2"
        echo "  $0 name 1                # Get name of workspace 1"
        echo "  $0 info                  # Show current workspace info"
        exit 1
        ;;
esac