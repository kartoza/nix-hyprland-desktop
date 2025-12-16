#!/usr/bin/env bash

# Waybar keyboard layout toggle script
# Toggles between configured keyboard layouts

# Read layouts from Wayfire config
WAYFIRE_CONFIG="${WAYFIRE_CONFIG:-/etc/xdg/wayfire/wayfire.ini}"
if [[ -f "$WAYFIRE_CONFIG" ]]; then
  # Extract xkb_layout line and get the layouts
  LAYOUTS=$(grep "^xkb_layout = " "$WAYFIRE_CONFIG" | cut -d'=' -f2 | tr -d ' ')
  IFS=',' read -ra LAYOUT_ARRAY <<< "$LAYOUTS"
  LAYOUT_PRIMARY="${LAYOUT_ARRAY[0]:-us}"
  LAYOUT_SECONDARY="${LAYOUT_ARRAY[1]:-pt}"
else
  # Fallback to default layouts
  LAYOUT_PRIMARY="us"
  LAYOUT_SECONDARY="pt"
fi

# State file to track current layout
STATE_FILE="$HOME/.local/state/keyboard-layout"
mkdir -p "$(dirname "$STATE_FILE")"

# Initialize state file if it doesn't exist
if [[ ! -f "$STATE_FILE" ]]; then
  echo "$LAYOUT_PRIMARY" >"$STATE_FILE"
fi

# Get current layout from state file
get_current_layout() {
  cat "$STATE_FILE" 2>/dev/null || echo "$LAYOUT_PRIMARY"
}

# Set layout using available tools
set_layout() {
  local layout="$1"

  # Simulate Alt+Shift keystroke to trigger Wayfire layout switching
  if command -v wtype >/dev/null 2>&1; then
    # Use wtype to send Alt+Shift combination
    wtype -M alt -M shift -m shift -m alt
  elif command -v ydotool >/dev/null 2>&1; then
    # Alternative: use ydotool
    ydotool key alt:1 shift:1 shift:0 alt:0
  fi
  
  # Update state file to track our intended layout
  echo "$layout" >"$STATE_FILE"
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

