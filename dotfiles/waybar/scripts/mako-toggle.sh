#!/usr/bin/env bash
# Toggle mako Do Not Disturb mode using makoctl

STATE_FILE="/tmp/mako-dnd-state"
if [ -f "$STATE_FILE" ]; then
  # DND is ON, turn it OFF
  makoctl mode -r dnd
  rm "$STATE_FILE"
  notify-send "Notifications" "Notifications enabled" --app-name="System" --urgency=low
  echo '{"text": "", "alt": "enabled", "tooltip": "Notifications enabled", "class": "enabled"}'
  # Kill the mako process
  pkill mako
else
  # DND is OFF, turn it ON
  # Send a final notification before enabling DND
  notify-send "Do Not Disturb" "Notifications disabled until manually re-enabled" --app-name="System" --urgency=low
  sleep 1

  # Enable Do Not Disturb mode
  makoctl mode -s dnd
  touch "$STATE_FILE"
  echo '{"text": "", "alt": "disabled", "tooltip": "Do Not Disturb (notifications silenced)", "class": "disabled"}'
fi
