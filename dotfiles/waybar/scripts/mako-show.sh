#!/usr/bin/env bash
# Show notification list when count is clicked

STATE_FILE="/tmp/mako-dnd-state"

# First check if mako is running as a process
if ! pgrep -x mako >/dev/null 2>&1; then
  # Mako is not running - just exit silently (offline response)
  exit 0
fi

if [ -f "$STATE_FILE" ]; then
  # DND is ON - notifications disabled
  notify-send "Notifications" "Notifications are currently disabled" --app-name="System" --urgency=low
  exit 0
fi

# Check systemd service status
if ! systemctl --user is-active mako.service >/dev/null 2>&1; then
  # Service is not active
  notify-send "Error" "Notification service is not running" --app-name="System" --urgency=critical
  exit 1
fi

# Get notification count
COUNT=$(makoctl list 2>/dev/null | grep -c "^Notification" || echo "0")

if [ "$COUNT" -eq 0 ]; then
  notify-send "Notifications" "No pending notifications" --app-name="System" --urgency=low
else
  # Show all notifications by making them visible temporarily
  makoctl mode -r do-not-disturb 2>/dev/null

  # Wait a moment for them to appear
  sleep 0.5

  # Show summary notification
  notify-send "Notifications" "Showing $COUNT pending notifications" --app-name="System" --urgency=low

  # After 10 seconds, hide them again (user can dismiss individually)
  (sleep 10 && makoctl mode -a do-not-disturb 2>/dev/null) &
fi
