#!/usr/bin/env bash

# wshowkeys status script for waybar
# Returns JSON status for wshowkeys toggle widget

PIDFILE="$XDG_RUNTIME_DIR/wshowkeys.pid"

# Check if wshowkeys is running
if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
  # wshowkeys is running
  echo '{"text": "󰌌", "class": "active", "tooltip": "Key display: ON (Meta+- to toggle)"}'
else
  # wshowkeys is not running
  echo '{"text": "󰌌", "class": "inactive", "tooltip": "Key display: OFF (Meta+- to toggle)"}'
fi

