#!/usr/bin/env bash
# by Tim Sutton (2025)
# ----------------------------------------------------- 

# Emoji picker using fuzzel - integrated with ML4W style

set -euo pipefail

# Use the existing fuzzel emoji script with proper data
EMOJI="$(sed '1,/^### DATA ###$/d' /etc/xdg/hypr/scripts/fuzzel-emoji | fuzzel \
    --dmenu \
    --prompt="🙂 Emoji: " \
    --width=48 \
    --lines=20 \
    --font="JetBrains Mono:size=12" \
    --background-color=1a110fdd \
    --text-color=f1dfdaff \
    --match-color=ffb59dff \
    --selection-color=723520ff \
    --selection-text-color=ffdbd0ff \
    --border-color=ffb59dff \
    --border-width=2 \
    --match-mode=exact | cut -d ' ' -f 1 | tr -d '\n')"

if [ -n "$EMOJI" ]; then
    # Type the emoji and copy to clipboard
    wtype "$EMOJI"
    wl-copy "$EMOJI"
    notify-send "Emoji Picker" "Typed and copied: $EMOJI" --icon=face-smile
fi
