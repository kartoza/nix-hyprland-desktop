#!/usr/bin/env bash
# Power profile switcher for waybar
# Uses power-profiles-daemon if available, otherwise uses CPU governor

# Check if power-profiles-daemon is available
if command -v powerprofilesctl &> /dev/null; then
    CURRENT=$(powerprofilesctl get)
    
    if [ "$1" == "cycle" ]; then
        # Cycle through profiles
        case "$CURRENT" in
            "power-saver")
                powerprofilesctl set balanced
                ;;
            "balanced")
                powerprofilesctl set performance
                ;;
            "performance")
                powerprofilesctl set power-saver
                ;;
        esac
        CURRENT=$(powerprofilesctl get)
    fi
    
    # Output JSON for waybar
    case "$CURRENT" in
        "power-saver")
            echo '{"text": "󰌪 L", "class": "power-saver", "tooltip": "Power Saver Mode - Maximum battery life"}'
            ;;
        "balanced")
            echo '{"text": "󰾅 M", "class": "balanced", "tooltip": "Balanced Mode - Normal performance"}'
            ;;
        "performance")
            echo '{"text": "󰓅 H", "class": "performance", "tooltip": "Performance Mode - Maximum speed"}'
            ;;
        *)
            echo '{"text": "󰾅 ?", "class": "balanced", "tooltip": "Unknown power profile"}'
            ;;
    esac
else
    # Fallback: just show a static message
    echo '{"text": "󰾅 Power", "class": "balanced", "tooltip": "power-profiles-daemon not available"}'
fi
