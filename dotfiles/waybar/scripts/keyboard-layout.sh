#!/usr/bin/env bash

# Waybar keyboard layout toggle script for Hyprland
# Switches between US and Portuguese layouts using hyprctl

# Get main keyboard device name
get_main_keyboard() {
  hyprctl devices -j | jq -r '.keyboards[] | select(.main == true) | .name' | head -1
}

# Get current layout from Hyprland
get_current_layout() {
  local main_kb=$(get_main_keyboard)
  if [[ -z "$main_kb" ]]; then
    echo "us"
    return
  fi
  
  local active_keymap=$(hyprctl devices -j | jq -r ".keyboards[] | select(.name == \"$main_kb\") | .active_keymap")
  case "$active_keymap" in
    *"Portuguese"*) echo "pt" ;;
    *) echo "us" ;;
  esac
}

# Toggle between US and Portuguese layouts
toggle_layout() {
  local main_kb=$(get_main_keyboard)
  if [[ -z "$main_kb" ]]; then
    echo "EN"
    return
  fi
  
  local current=$(get_current_layout)
  
  if [[ "$current" == "us" ]]; then
    # Switch to Portuguese (group 1)
    hyprctl switchxkblayout "$main_kb" 1 >/dev/null 2>&1
    echo "PT"
  else
    # Switch to US (group 0)
    hyprctl switchxkblayout "$main_kb" 0 >/dev/null 2>&1
    echo "EN"
  fi
}

# Get display name for current layout
get_display_name() {
  local layout=$(get_current_layout)
  case "$layout" in
    "us") echo "EN" ;;
    "pt") echo "PT" ;;
    *) echo "${layout^^}" ;;
  esac
}

# Handle command line arguments
case "${1}" in
  toggle)
    toggle_layout
    ;;
  *)
    get_display_name
    ;;
esac

