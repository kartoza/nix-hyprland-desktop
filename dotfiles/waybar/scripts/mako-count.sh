#!/usr/bin/env bash
# Get notification count for waybar display

STATE_FILE="/tmp/mako-dnd-state"

if [ -f "$STATE_FILE" ]; then
    # DND is ON - service is disabled, no count
    echo '{"text": "", "alt": "disabled", "tooltip": "Notifications disabled", "class": "disabled"}'
else
    # Check systemd service status
    if systemctl --user is-active mako.service >/dev/null 2>&1; then
        # Service is active - get notification count
        COUNT=$(makoctl list 2>/dev/null | grep -c "^Notification" || echo "0")
        if [ "$COUNT" -eq 0 ]; then
            echo '{"text": "", "alt": "enabled", "tooltip": "No pending notifications", "class": "enabled"}'
        else
            echo "{\"text\": \"$COUNT\", \"alt\": \"enabled\", \"tooltip\": \"$COUNT pending notifications\", \"class\": \"enabled\"}"
        fi
    else
        # Service is not active
        echo '{"text": "!", "alt": "error", "tooltip": "Notification service stopped", "class": "error"}'
    fi
fi