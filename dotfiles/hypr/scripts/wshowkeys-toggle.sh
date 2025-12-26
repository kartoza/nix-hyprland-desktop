#!/usr/bin/env bash
#  __          __ _____ _    _  ____  _____  _  __ _______     __  _____ 
#  \ \        / /|  ___| |  | |/ __ \|  __ \| |/ /|  ____\ \  / / |  ___|
#   \ \  /\  / / | |___| |__| | |  | | |__) | ' / | |__   \ \/ /  | |___ 
#    \ \/  \/ /  |  ___|  __  | |  | |  _  /|  <  |  __|   \  /   |___  |
#     \  /\  /   | |___| |  | | |__| | | \ \| . \ | |____   ||     ___| |
#      \/  \/    |_____|_|  |_|\____/|_|  \_\_|\_\|______|  ||    |_____|
#
# by Tim Sutton (2025) - Integrated with ML4W style
# ----------------------------------------------------- 

# wshowkeys toggle script for Hyprland
# Shows on-screen key display with Kartoza theming

PIDFILE="$XDG_RUNTIME_DIR/wshowkeys.pid"

# Check if wshowkeys is running
if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
    # wshowkeys is running, kill it
    /usr/bin/pkill wshowkeys
    /usr/bin/rm -f "$PIDFILE"
    /usr/bin/notify-send "Key Display" "On-screen keys disabled" --icon=input-keyboard --urgency=low
    echo "disabled"
else
    # wshowkeys is not running, start it with Kartoza theming
    # Colors match the Kartoza orange theme: #DF9E2F (orange), dark background
    /usr/bin/wshowkeys \
        --font="JetBrains Mono" \
        --font-size=24 \
        --timeout=2 \
        --margin=20 \
        --anchor=top \
        --anchor=right \
        --background="#1a110f" \
        --foreground="#f1dfda" \
        --special="#ffb59d" &
    
    echo $! >"$PIDFILE"
    /usr/bin/notify-send "Key Display" "On-screen keys enabled" --icon=input-keyboard --urgency=low
    echo "enabled"
fi