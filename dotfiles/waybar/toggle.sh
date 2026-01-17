#!/usr/bin/env bash
# Waybar toggle script
# Toggles waybar visibility (kills if running, starts if not)

if pgrep -x waybar > /dev/null; then
    # Waybar is running, kill it
    pkill waybar
else
    # Waybar is not running, start it
    waybar -c /etc/xdg/waybar/config -s /etc/xdg/waybar/style.css &
    disown
fi
