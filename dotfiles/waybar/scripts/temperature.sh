#!/usr/bin/env bash
# Temperature monitoring script for waybar
# Returns color-coded temperature with appropriate class

# Get CPU temperature (trying multiple sources)
if [ -f /sys/class/thermal/thermal_zone0/temp ]; then
    TEMP=$(cat /sys/class/thermal/thermal_zone0/temp)
    TEMP=$((TEMP / 1000))
elif command -v sensors &> /dev/null; then
    TEMP=$(sensors | grep -i 'Core 0' | awk '{print $3}' | sed 's/+//;s/°C//' | cut -d'.' -f1)
    if [ -z "$TEMP" ]; then
        TEMP=$(sensors | grep -i 'Package' | awk '{print $4}' | sed 's/+//;s/°C//' | cut -d'.' -f1)
    fi
else
    # Fallback if no temperature source available
    echo '{"text": "󰔏 N/A", "class": "normal", "tooltip": "Temperature sensor not available"}'
    exit 0
fi

# Determine class based on temperature thresholds
# Normal: < 50°C (white)
# Warm: 50-65°C (grey)
# Hot: 65-80°C (blue)
# Critical: > 80°C (gold with animation)

if [ "$TEMP" -lt 50 ]; then
    CLASS="normal"
    TOOLTIP="Temperature: ${TEMP}°C - Normal"
elif [ "$TEMP" -lt 65 ]; then
    CLASS="warm"
    TOOLTIP="Temperature: ${TEMP}°C - Warm"
elif [ "$TEMP" -lt 80 ]; then
    CLASS="hot"
    TOOLTIP="Temperature: ${TEMP}°C - Hot"
else
    CLASS="critical"
    TOOLTIP="Temperature: ${TEMP}°C - Critical! Check cooling"
fi

# Output JSON for waybar
echo "{\"text\": \"󰔏 ${TEMP}°C\", \"class\": \"${CLASS}\", \"tooltip\": \"${TOOLTIP}\"}"
