#!/usr/bin/env bash
# by Tim Sutton (2025)
# -----------------------------------------------------

# Clipboard history with clipse (secure) + fuzzel integration

# Function to start clipboard monitoring using clipse
start_monitor() {
  # Kill any existing clipboard monitors
  pkill -f "clipse.*listen"
  pkill -f "wl-paste.*clipboard.sh"

  # Start clipse listener for secure clipboard storage
  clipse listen &

  echo "Clipse clipboard monitor started (secure storage)"
}

# Function to show clipboard history with fuzzel using clipse
show_history() {
  # Get clipboard history from clipse in JSON format
  if ! command -v clipse >/dev/null 2>&1; then
    notify-send "Clipboard Error" "Clipse not found - clipboard history unavailable"
    return 1
  fi

  # Get clipboard entries from clipse
  clipse_output=$(clipse list 2>/dev/null)

  if [ -z "$clipse_output" ]; then
    notify-send "Clipboard" "No clipboard history found"
    return
  fi

  # Create a numbered list for fuzzel display
  temp_display="$(mktemp)"
  temp_mapping="$(mktemp)"

  # Process clipboard history from clipse output
  line_num=1
  echo "$clipse_output" | while IFS= read -r line; do
    # Skip empty lines
    [ -z "$line" ] && continue

    # Truncate long lines for display
    if [ ${#line} -gt 80 ]; then
      display_line="$(echo "$line" | cut -c1-77)..."
    else
      display_line="$line"
    fi

    # Replace newlines with ↵ symbol for display
    display_line="$(echo "$display_line" | tr '\n' '↵')"

    # Show line number and preview
    printf "%02d: %s\n" "$line_num" "$display_line" >>"$temp_display"

    # Store mapping of line number to full content
    printf "%02d:%s\n" "$line_num" "$line" >>"$temp_mapping"

    line_num=$((line_num + 1))
  done

  # Check if we have any entries
  if [ ! -s "$temp_display" ]; then
    notify-send "Clipboard" "No clipboard history found"
    rm "$temp_display" "$temp_mapping"
    return
  fi

  # Use fuzzel to select from clipboard history
  selected=$(cat "$temp_display" | fuzzel \
    --dmenu \
    --prompt="Clipboard History: " \
    --width=80 \
    --lines=15 \
    --font="JetBrains Mono:size=11" \
    --background-color=1a110fdd \
    --text-color=f1dfdaff \
    --match-color=ffb59dff \
    --selection-color=723520ff \
    --selection-text-color=ffdbd0ff \
    --border-color=ffb59dff \
    --border-width=2)

  if [ -n "$selected" ]; then
    # Extract line number
    line_num=$(echo "$selected" | cut -d: -f1)

    # Get full content from mapping
    full_content=$(grep "^$line_num:" "$temp_mapping" | cut -d: -f2-)

    if [ -n "$full_content" ]; then
      # Copy to clipboard using clipse
      echo -n "$full_content" | wl-copy
      notify-send "Clipboard" "Copied to clipboard"
    fi
  fi

  # Clean up temp files
  rm "$temp_display" "$temp_mapping"
}

# Function to clear clipboard history using clipse
clear_history() {
  if command -v clipse >/dev/null 2>&1; then
    clipse clear 2>/dev/null
    notify-send "Clipboard" "History cleared (clipse)"
  else
    notify-send "Clipboard Error" "Clipse not found"
  fi
}

# Function to show clipboard stats using clipse
show_stats() {
  if command -v clipse >/dev/null 2>&1; then
    count=$(clipse list 2>/dev/null | wc -l)
    notify-send "Clipboard Stats" "$count entries in clipse history"
  else
    notify-send "Clipboard Error" "Clipse not found"
  fi
}

# Main function
case "$1" in
"monitor")
  start_monitor
  ;;
"show")
  show_history
  ;;
"clear")
  clear_history
  ;;
"stats")
  show_stats
  ;;
*)
  echo "Usage: $0 {monitor|show|clear|stats}"
  echo "  monitor - Start clipboard monitoring"
  echo "  show    - Show clipboard history with fuzzel"
  echo "  clear   - Clear clipboard history"
  echo "  stats   - Show clipboard statistics"
  exit 1
  ;;
esac
