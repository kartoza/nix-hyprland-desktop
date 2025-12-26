#!/usr/bin/env bash
#   ____   _____ _____  ___  _____  ________   _____  _____  _____ ____  ____  _____ _____  
#  / ___| / ____|  __ \|  __|  ___||   ___  \ |  __ \| ____|/ ____|/ _  \|  _ \|  __ \|  ___| 
#  \___ \| |    | |__) | |__| |__  |  |   \  \| |__) | |__ | |    | | | || |_) | |__) | |__   
#   ___) | |    |  _  /|  __|  __| |  |   |  ||  _  /|  __|| |    | | | ||  _ <|  _  /|  __|  
#  |____/| |____| | \ \| |__| |___ |  |___|  || | \ \| |___| |____| |_| || |_) | | \ \| |___  
#        \_____\_|  \_\___|_____|\_|       \_/|_|  \_\______|\_____\_____/|____/|_|  \_\_____|
#
# by Tim Sutton (2025) - Based on original Kartoza config
# ----------------------------------------------------- 

# Screen recording toggle script for Hyprland with multi-monitor support
# Integrated with ML4W style and modern Wayland tools

PIDFILE="/tmp/wf-recorder.pid"
STATUSFILE="/tmp/wf-recorder.status"
VIDEOS_DIR="$HOME/Videos/Screencasts"

# Ensure videos directory exists
mkdir -p "$VIDEOS_DIR"

# Function to get focused monitor for Hyprland
get_focused_output() {
    # Try to get focused monitor from hyprctl
    hyprctl monitors -j | jq -r '.[] | select(.focused==true) | .name' 2>/dev/null
}

# Check if recording is active
if [ -f "$PIDFILE" ] && kill -0 "$(cat $PIDFILE)" 2>/dev/null; then
    # Stop recording
    kill "$(cat $PIDFILE)" 2>/dev/null
    rm -f "$PIDFILE"
    echo "stopped" >"$STATUSFILE"
    notify-send "Screen Recording" "Recording stopped and saved to Videos/Screencasts" --icon=video-x-generic --urgency=normal
else
    # Start recording
    timestamp=$(date +%Y%m%d-%H%M%S)
    
    # Get the focused output (monitor)
    focused_output=$(get_focused_output)
    
    # Fallback to first available output if no focused output
    if [ -z "$focused_output" ] || [ "$focused_output" == "null" ]; then
        focused_output=$(hyprctl monitors -j | jq -r '.[0].name' 2>/dev/null)
    fi
    
    if [ -n "$focused_output" ] && [ "$focused_output" != "null" ]; then
        output_file="$VIDEOS_DIR/screenrecording-$focused_output-$timestamp.mp4"
        notify-send "Screen Recording" "Recording $focused_output..." --icon=video-x-generic --urgency=normal
        
        # Start wf-recorder for specific output with better quality settings
        wf-recorder \
            --output="$focused_output" \
            --file="$output_file" \
            --codec=libx264 \
            --audio \
            --pixel-format=yuv420p &
    else
        # Fallback to full screen recording
        output_file="$VIDEOS_DIR/screenrecording-$timestamp.mp4"
        notify-send "Screen Recording" "Recording all screens..." --icon=video-x-generic --urgency=normal
        
        # Start wf-recorder for all outputs
        wf-recorder \
            --file="$output_file" \
            --codec=libx264 \
            --audio \
            --pixel-format=yuv420p &
    fi
    
    echo $! >"$PIDFILE"
    echo "recording" >"$STATUSFILE"
fi