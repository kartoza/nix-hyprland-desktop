#!/usr/bin/env bash

# Waybar keyboard layout toggle script for Hyprland
# Toggles between configured keyboard layouts and detects external changes

# Read layouts from Hyprland config (check user config first)
HYPRLAND_CONFIG="$(xdg-config-path hypr/hyprland.conf 2>/dev/null || echo "/etc/xdg/hypr/hyprland.conf")"
if [[ -f "$HYPRLAND_CONFIG" ]]; then
  # Extract kb_layout line and get the layouts
  LAYOUTS=$(grep "kb_layout = " "$HYPRLAND_CONFIG" | head -1 | cut -d'=' -f2 | tr -d ' ')
  IFS=',' read -ra LAYOUT_ARRAY <<< "$LAYOUTS"
  LAYOUT_PRIMARY="${LAYOUT_ARRAY[0]:-us}"
  LAYOUT_SECONDARY="${LAYOUT_ARRAY[1]:-pt}"
else
  # Fallback to default layouts
  LAYOUT_PRIMARY="us"
  LAYOUT_SECONDARY="pt"
fi

# Get current layout using xkblayout-state if available
get_current_layout() {
  if command -v xkblayout-state >/dev/null 2>&1; then
    # Use xkblayout-state to get the current active layout
    local current_group
    current_group=$(xkblayout-state print %c 2>/dev/null)
    
    # Map group number to layout name
    case "$current_group" in
      0) echo "$LAYOUT_PRIMARY" ;;
      1) echo "$LAYOUT_SECONDARY" ;;
      *) echo "$LAYOUT_PRIMARY" ;;  # fallback to primary
    esac
  else
    # Fallback: use first layout from config
    echo "$LAYOUT_PRIMARY"
  fi
}

# Set layout using available tools
set_layout() {
  local target_layout="$1"
  
  if command -v xkblayout-state >/dev/null 2>&1; then
    # Use xkblayout-state to set layout directly by group number
    case "$target_layout" in
      "$LAYOUT_PRIMARY") xkblayout-state set 0 ;;
      "$LAYOUT_SECONDARY") xkblayout-state set 1 ;;
    esac
  else
    # Fallback: Simulate Alt+Shift keystroke to toggle
    if command -v wtype >/dev/null 2>&1; then
      wtype -M alt -M shift -m shift -m alt
    elif command -v ydotool >/dev/null 2>&1; then
      ydotool key alt:1 shift:1 shift:0 alt:0
    fi
  fi
}

# Get display name for layout code
get_display_name() {
  local layout="$1"
  case "$layout" in
    "us") echo "EN" ;;
    "pt") echo "PT" ;;
    "de") echo "DE" ;;
    "fr") echo "FR" ;;
    "es") echo "ES" ;;
    "it") echo "IT" ;;
    *) echo "${layout^^}" ;;  # Uppercase the layout code as fallback
  esac
}

# Toggle layout
toggle_layout() {
  current=$(get_current_layout)
  if [[ "$current" == "$LAYOUT_PRIMARY" ]]; then
    set_layout "$LAYOUT_SECONDARY"
    get_display_name "$LAYOUT_SECONDARY"
  else
    set_layout "$LAYOUT_PRIMARY"
    get_display_name "$LAYOUT_PRIMARY"
  fi
}

# Display current layout for waybar
display_layout() {
  current=$(get_current_layout)
  get_display_name "$current"
}

case "${1}" in
toggle)
  toggle_layout
  ;;
*)
  display_layout
  ;;
esac

