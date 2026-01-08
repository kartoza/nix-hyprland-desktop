#!/usr/bin/env bash

# Generic monitor swapping script for Hyprland
# Swaps the positions of two monitors

# Get all connected monitors
monitors=$(hyprctl monitors -j | jq -r '.[] | "\(.name) \(.x) \(.y) \(.width) \(.height) \(.refreshRate) \(.scale)"')

if [ -z "$monitors" ]; then
    echo "No monitors found"
    exit 1
fi

# Count monitors
monitor_count=$(echo "$monitors" | wc -l)

if [ "$monitor_count" -lt 2 ]; then
    echo "Only one monitor detected. Nothing to swap."
    exit 0
fi

# Parse monitor info into arrays
declare -a names
declare -a x_positions
declare -a y_positions
declare -a widths
declare -a heights
declare -a refresh_rates
declare -a scales

i=0
while IFS=' ' read -r name x y width height refresh scale; do
    names[$i]="$name"
    x_positions[$i]="$x"
    y_positions[$i]="$y"
    widths[$i]="$width"
    heights[$i]="$height"
    refresh_rates[$i]="$refresh"
    scales[$i]="$scale"
    ((i++))
done <<< "$monitors"

# If more than 2 monitors, let user choose which two to swap
if [ "$monitor_count" -gt 2 ]; then
    echo "Multiple monitors detected:"
    for ((i=0; i<monitor_count; i++)); do
        echo "  [$i] ${names[$i]} (${widths[$i]}x${heights[$i]} at ${x_positions[$i]},${y_positions[$i]})"
    done
    echo ""
    echo "Usage: $0 [monitor1_index] [monitor2_index]"

    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "Please specify two monitor indices to swap"
        exit 1
    fi

    mon1=$1
    mon2=$2
else
    # Just two monitors, swap them
    mon1=0
    mon2=1
fi

# Validate indices
if [ "$mon1" -ge "$monitor_count" ] || [ "$mon2" -ge "$monitor_count" ]; then
    echo "Error: Invalid monitor index"
    exit 1
fi

# Determine which monitor is currently on the left (smaller X position)
if [ "${x_positions[$mon1]}" -lt "${x_positions[$mon2]}" ]; then
    left_mon=$mon1
    right_mon=$mon2
else
    left_mon=$mon2
    right_mon=$mon1
fi

# Swap: right monitor goes to x=0, left monitor goes after it
new_left_x=0
new_right_x="${widths[$right_mon]}"

# Assign new positions (swapped)
x_positions[$right_mon]=$new_left_x
x_positions[$left_mon]=$new_right_x

# Apply the new positions
echo "Swapping ${names[$mon1]} and ${names[$mon2]}..."

# First, move both monitors to temporary non-overlapping positions
hyprctl keyword monitor "${names[$mon1]},${widths[$mon1]}x${heights[$mon1]}@${refresh_rates[$mon1]},10000x0,${scales[$mon1]}"
hyprctl keyword monitor "${names[$mon2]},${widths[$mon2]}x${heights[$mon2]}@${refresh_rates[$mon2]},20000x0,${scales[$mon2]}"
sleep 0.2

# Now set both monitors to their final positions
hyprctl keyword monitor "${names[$mon1]},${widths[$mon1]}x${heights[$mon1]}@${refresh_rates[$mon1]},${x_positions[$mon1]}x${y_positions[$mon1]},${scales[$mon1]}"
hyprctl keyword monitor "${names[$mon2]},${widths[$mon2]}x${heights[$mon2]}@${refresh_rates[$mon2]},${x_positions[$mon2]}x${y_positions[$mon2]},${scales[$mon2]}"

# Wait for monitors to reconfigure
sleep 0.3

# Focus each monitor to reset cursor constraints
hyprctl dispatch focusmonitor "${names[$mon1]}"
sleep 0.1
hyprctl dispatch focusmonitor "${names[$mon2]}"

echo "Monitors swapped!"
