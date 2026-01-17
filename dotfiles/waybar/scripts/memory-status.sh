#!/usr/bin/env bash
# Memory monitoring script for waybar
# Shows pie chart icon based on memory utilization

# Circle slice icons (nf-md-circle-slice-1 through 8)
# These show progressively filled circle segments
ICON_0="󰝦"   # circle-outline (empty) - f0766
ICON_1="󰪞"   # circle-slice-1 - f0a9e
ICON_2="󰪟"   # circle-slice-2 - f0a9f
ICON_3="󰪠"   # circle-slice-3 - f0aa0
ICON_4="󰪡"   # circle-slice-4 - f0aa1
ICON_5="󰪢"   # circle-slice-5 - f0aa2
ICON_6="󰪣"   # circle-slice-6 - f0aa3
ICON_7="󰪤"   # circle-slice-7 - f0aa4
ICON_8="󰪥"   # circle-slice-8 (full) - f0aa5

# Get memory info from /proc/meminfo (in kB)
MEM_TOTAL=$(grep MemTotal /proc/meminfo | awk '{print $2}')
MEM_AVAILABLE=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
MEM_USED=$((MEM_TOTAL - MEM_AVAILABLE))

# Calculate percentage
PERCENTAGE=$((MEM_USED * 100 / MEM_TOTAL))

# Convert to GB for tooltip
USED_GB=$(echo "scale=1; $MEM_USED / 1048576" | bc)
TOTAL_GB=$(echo "scale=1; $MEM_TOTAL / 1048576" | bc)
AVAILABLE_GB=$(echo "scale=1; $MEM_AVAILABLE / 1048576" | bc)

# Select icon based on percentage (8 levels)
if [ "$PERCENTAGE" -lt 6 ]; then
    ICON="$ICON_0"
elif [ "$PERCENTAGE" -lt 18 ]; then
    ICON="$ICON_1"
elif [ "$PERCENTAGE" -lt 31 ]; then
    ICON="$ICON_2"
elif [ "$PERCENTAGE" -lt 44 ]; then
    ICON="$ICON_3"
elif [ "$PERCENTAGE" -lt 56 ]; then
    ICON="$ICON_4"
elif [ "$PERCENTAGE" -lt 69 ]; then
    ICON="$ICON_5"
elif [ "$PERCENTAGE" -lt 81 ]; then
    ICON="$ICON_6"
elif [ "$PERCENTAGE" -lt 94 ]; then
    ICON="$ICON_7"
else
    ICON="$ICON_8"
fi

# Determine class for color coding
if [ "$PERCENTAGE" -lt 50 ]; then
    CLASS="normal"
elif [ "$PERCENTAGE" -lt 75 ]; then
    CLASS="moderate"
elif [ "$PERCENTAGE" -lt 90 ]; then
    CLASS="high"
else
    CLASS="critical"
fi

# Output JSON for waybar
TOOLTIP="Memory Usage: ${PERCENTAGE}%\nUsed: ${USED_GB}GB / ${TOTAL_GB}GB\nAvailable: ${AVAILABLE_GB}GB"
echo "{\"text\": \"${ICON}\", \"class\": \"${CLASS}\", \"tooltip\": \"${TOOLTIP}\", \"percentage\": ${PERCENTAGE}}"
