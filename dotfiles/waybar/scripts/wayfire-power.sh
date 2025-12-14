#!/usr/bin/env bash
# Power menu script for Wayfire - creates temp config with correct logout command

TEMP_CONFIG="/tmp/nwgbar-wayfire.json"

# Create config with wayfire-specific logout command
cat >"$TEMP_CONFIG" <<'EOF'
[
  {
    "name": "Lock screen",
    "exec": "swaylock -f",
    "icon": "system-lock-screen"
  },
  {
    "name": "Logout",
    "exec": "pkill wayfire",
    "icon": "system-log-out"
  },
  {
    "name": "Reboot",
    "exec": "systemctl reboot",
    "icon": "system-reboot"
  },
  {
    "name": "Shutdown",
    "exec": "systemctl poweroff",
    "icon": "system-shutdown"
  }
]
EOF

# Launch nwgbar with wayfire config
nwgbar -t "$TEMP_CONFIG" -c ~/.config/nwg-launchers/nwgbar/style.css -s 48

# Clean up
rm -f "$TEMP_CONFIG"

