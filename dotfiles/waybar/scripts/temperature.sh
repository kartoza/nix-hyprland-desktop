#!/usr/bin/env bash
# Temperature monitoring script for waybar
# Returns color-coded temperature with appropriate class and thermometer icon

# Thermometer icons (nf-md) showing fill levels
ICON_EMPTY="󰔏"    # nf-md-thermometer-low (f050f) - cold
ICON_QUARTER="󰔏"  # nf-md-thermometer-low (f050f) - cool
ICON_HALF="󰔐"     # nf-md-thermometer (f0510) - normal
ICON_THREE="󰔑"    # nf-md-thermometer-high (f0511) - warm
ICON_FULL="󰸁"     # nf-md-thermometer-alert (f0e01) - hot/critical

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
    echo "{\"text\": \"$ICON_HALF\", \"class\": \"normal\", \"tooltip\": \"Temperature sensor not available\"}"
    exit 0
fi

# Determine class and icon based on temperature thresholds
# Cold: < 35°C
# Cool: 35-50°C
# Normal: 50-65°C
# Warm: 65-80°C
# Critical: > 80°C

if [ "$TEMP" -lt 35 ]; then
    CLASS="normal"
    ICON="$ICON_EMPTY"
    TOOLTIP="CPU Temperature: ${TEMP}°C\nStatus: Cold"
elif [ "$TEMP" -lt 50 ]; then
    CLASS="normal"
    ICON="$ICON_QUARTER"
    TOOLTIP="CPU Temperature: ${TEMP}°C\nStatus: Cool"
elif [ "$TEMP" -lt 65 ]; then
    CLASS="warm"
    ICON="$ICON_HALF"
    TOOLTIP="CPU Temperature: ${TEMP}°C\nStatus: Normal"
elif [ "$TEMP" -lt 80 ]; then
    CLASS="hot"
    ICON="$ICON_THREE"
    TOOLTIP="CPU Temperature: ${TEMP}°C\nStatus: Warm"
else
    CLASS="critical"
    ICON="$ICON_FULL"
    TOOLTIP="CPU Temperature: ${TEMP}°C\nStatus: Critical! Check cooling"
fi

# Output JSON for waybar (icon only, temp in tooltip)
echo "{\"text\": \"${ICON}\", \"class\": \"${CLASS}\", \"tooltip\": \"${TOOLTIP}\"}"
