#!/usr/bin/env bash
# Get current mako notification daemon state

STATE_FILE="$XDG_RUNTIME_DIR/mako-dnd-state"

# Function to check if mako is running
is_mako_running() {
    pgrep -x mako >/dev/null 2>&1
}

# Function to check if mako is in DND mode
is_dnd_active() {
    makoctl mode 2>/dev/null | grep -q "dnd"
}

# Check current state
if [ -f "$STATE_FILE" ]; then
    # DND state file exists - notifications should be disabled
    if is_mako_running; then
        if is_dnd_active; then
            echo '{"text": "", "alt": "disabled", "tooltip": "Do Not Disturb - notifications silenced (click to enable)", "class": "disabled"}'
        else
            # State file exists but DND mode not active - inconsistent state
            echo '{"text": "", "alt": "warning", "tooltip": "Notification state inconsistent (click to refresh)", "class": "warning"}'
        fi
    else
        # Mako not running but DND state exists
        echo '{"text": "", "alt": "disabled", "tooltip": "Notifications disabled - mako stopped (click to enable)", "class": "disabled"}'
    fi
else
    # No DND state file - notifications should be enabled
    if is_mako_running; then
        if is_dnd_active; then
            # DND mode active but no state file - inconsistent
            echo '{"text": "", "alt": "warning", "tooltip": "DND mode active but state unclear (click to refresh)", "class": "warning"}'
        else
            echo '{"text": "", "alt": "enabled", "tooltip": "Notifications enabled (click to disable)", "class": "enabled"}'
        fi
    else
        # Mako not running and no DND state - normal, will auto-start when needed
        echo '{"text": "", "alt": "enabled", "tooltip": "Notifications enabled (auto-start) - click to disable", "class": "enabled"}'
    fi
fi