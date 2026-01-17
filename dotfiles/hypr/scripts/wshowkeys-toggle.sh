#!/usr/bin/env bash
# by Tim Sutton (2025) - Integrated with ML4W style
# -----------------------------------------------------

# wshowkeys toggle script for Hyprland
# Shows on-screen key display with Kartoza theming

PIDFILE="$XDG_RUNTIME_DIR/wshowkeys.pid"

# Check if wshowkeys is running
if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
  # wshowkeys is running, kill it
  pkill wshowkeys
  rm -f "$PIDFILE"
  notify-send "Key Display" "On-screen keys disabled" --icon=input-keyboard --urgency=low
  echo "disabled"
else
  # wshowkeys is not running, start it with Kartoza theming
  # Colors: Orange text (#DF9E2F), Blue special keys (#569FC6), dark background
  # Font: Open Gorton - keycap style font (MIT licensed)
  wshowkeys \
    -F "Open Gorton 24" \
    -t 2 \
    -m 20 \
    -a top \
    -a right \
    -b "#1a110f" \
    -f "#DF9E2F" \
    -s "#569FC6" &

  echo $! >"$PIDFILE"
  notify-send "Key Display" "On-screen keys enabled" --icon=input-keyboard --urgency=low
  echo "enabled"
fi
