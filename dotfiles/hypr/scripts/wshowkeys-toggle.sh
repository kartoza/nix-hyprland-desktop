#!/usr/bin/env bash

# wshowkeys toggle script for Wayfire
# Toggles wshowkeys on-screen key display on/off

PIDFILE="$XDG_RUNTIME_DIR/wshowkeys.pid"

# Check if wshowkeys is running
if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
  # wshowkeys is running, kill it
  pkill showkey
  rm -f "$PIDFILE"
  notify-send "wshowkeys" "Key display disabled" --icon=input-keyboard
  echo "disabled"
else
  # wshowkeys is not running, start it
  wshowkeys -F "Nurito 90" -t 1 -m 90 -a top -a right -b "#51585D" -f "#ffffff" -s "#E4AE52"
  echo $! >"$PIDFILE"
  notify-send "wshowkeys" "Key display enabled" --icon=input-keyboard
  echo "enabled"
fi
