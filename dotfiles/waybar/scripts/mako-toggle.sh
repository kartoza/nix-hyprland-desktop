#!/usr/bin/env bash
# Toggle mako notifications using DND mode
# This keeps mako running but silences notifications

STATE_FILE="$XDG_RUNTIME_DIR/mako-dnd-state"

# Function to ensure mako is running
ensure_mako_running() {
    if ! pgrep -x mako >/dev/null 2>&1; then
        mako -c "$(xdg-config-path mako/kartoza)" &
        sleep 0.5  # Give mako time to start
    fi
}

if [ -f "$STATE_FILE" ]; then
    # DND is ON, turn it OFF
    rm -f "$STATE_FILE"
    
    # Ensure mako is running
    ensure_mako_running
    
    # Remove DND mode - this will show notifications again
    makoctl mode -r dnd 2>/dev/null || true
    
    # Send confirmation notification
    sleep 0.2
    notify-send "Notifications" "Notifications enabled" --app-name="System" --urgency=low
    
    echo '{"text": "", "alt": "enabled", "tooltip": "Notifications enabled (click to disable)", "class": "enabled"}'
else
    # DND is OFF, turn it ON
    
    # Ensure mako is running for the final notification
    ensure_mako_running
    
    # Send final notification before enabling DND
    notify-send "Do Not Disturb" "Notifications will be silenced" --app-name="System" --urgency=low
    sleep 1
    
    # Enable DND mode - this silences all future notifications while keeping mako running
    makoctl mode -s dnd 2>/dev/null
    
    # Create state file
    touch "$STATE_FILE"
    
    echo '{"text": "", "alt": "disabled", "tooltip": "Do Not Disturb - notifications silenced (click to enable)", "class": "disabled"}'
fi