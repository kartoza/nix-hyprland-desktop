#!/usr/bin/env bash
# Get current mako notification daemon state using systemd service

STATE_FILE="/tmp/mako-dnd-state"

# First check if mako is running as a process
if ! pgrep -x mako >/dev/null 2>&1; then
  # Mako is not running at all
  echo '{"text": "", "alt": "disabled", "tooltip": "Mako notification daemon is not running", "class": "disabled"}'
  exit 0
fi

if [ -f "$STATE_FILE" ]; then
  # DND is ON - systemd service is disabled
  echo '{"text": "", "alt": "disabled", "tooltip": "Do Not Disturb (notification daemon disabled)", "class": "disabled"}'
else
  if makoctl is-active &>/dev/null; then
    echo '{"text": "", "alt": "enabled", "tooltip": "Notifications enabled", "class": "enabled"}'
  else
    echo '{"text": "", "alt": "error", "tooltip": "Notification service stopped unexpectedly", "class": "error"}'
  fi
fi
