#!/usr/bin/env bash

# wshowkeys toggle script for Wayfire
# Toggles wshowkeys on-screen key display on/off

PIDFILE="$XDG_RUNTIME_DIR/wshowkeys.pid"

# Check if wshowkeys is running
if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
    # wshowkeys is running, kill it
    kill "$(cat "$PIDFILE")"
    rm -f "$PIDFILE"
    notify-send "wshowkeys" "Key display disabled" --icon=input-keyboard
    echo "disabled"
else
    # wshowkeys is not running, start it
    wshowkeys -a bottom-right -t 2 -F "DejaVu Sans Mono:size=14" &
    echo $! > "$PIDFILE"
    notify-send "wshowkeys" "Key display enabled" --icon=input-keyboard
    echo "enabled"
fi