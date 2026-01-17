#!/usr/bin/env bash
# Waybar launch/reload script
# Kills any running waybar and starts a fresh instance

# Kill existing waybar instances
pkill waybar 2>/dev/null

# Wait briefly for processes to terminate
sleep 0.2

# Launch waybar with system config
waybar -c /etc/xdg/waybar/config -s /etc/xdg/waybar/style.css &

disown
