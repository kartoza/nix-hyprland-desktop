#!/usr/bin/env bash
# Window switcher using wofi for Wayfire

# Get list of windows
windows=$(wayfire -c list-views | grep -v "^$" | \
    awk '{$1=""; print substr($0,2)}' | \
    nl -w 3 -n rn)

# Show menu and get selection
selection=$(echo "$windows" | wofi --dmenu -i -p "Switch to window:" | awk '{print $1}')

# Switch to selected window
if [ -n "$selection" ]; then
    wayfire -c focus-view "$selection"
fi
