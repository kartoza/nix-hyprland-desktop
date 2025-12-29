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
# Enhanced with separate audio recording and post-processing

VIDEO_PIDFILE="/tmp/wf-recorder.pid"
AUDIO_PIDFILE="/tmp/pw-recorder.pid"
STATUSFILE="/tmp/wf-recorder.status"
VIDEO_FILE="/tmp/wf-recorder.video"
AUDIO_FILE="/tmp/wf-recorder.audio"
VIDEOS_DIR="$HOME/Videos/Screencasts"

# Ensure videos directory exists
mkdir -p "$VIDEOS_DIR"

# Function to get focused monitor for Hyprland
get_focused_output() {
    # Try to get focused monitor from hyprctl
    hyprctl monitors -j | jq -r '.[] | select(.focused==true) | .name' 2>/dev/null
}

# Function to merge audio and video
merge_recordings() {
    local video_file="$1"
    local audio_file="$2"
    local output_file="${video_file%.mp4}-merged.mp4"

    # Wait a moment for files to be fully written
    sleep 1

    # Merge video and audio using ffmpeg
    if ffmpeg -y -i "$video_file" -i "$audio_file" \
        -c:v copy -c:a aac -strict experimental \
        -shortest \
        "$output_file" 2>&1 | grep -q "Output"; then

        # Remove temporary files
        rm -f "$video_file" "$audio_file"

        # Get the output directory for the notification action
        output_dir=$(dirname "$output_file")
        filename=$(basename "$output_file")

        # Send notification with action using notify-send
        # The -A flag adds an action button (supported by mako)
        notify-send -A "open=Open Folder" \
            "Screen Recording Complete" \
            "$filename saved!\n\nClick to open folder" \
            --icon=video-x-generic \
            --urgency=normal | {
            read -r action
            if [ "$action" = "open" ]; then
                nautilus "$output_dir" &
            fi
        } &
    else
        notify-send "Screen Recording Error" \
            "Failed to merge recordings.\nFiles saved separately in Videos/Screencasts" \
            --icon=dialog-error \
            --urgency=critical
    fi
}

# Check if recording is active
if [ -f "$VIDEO_PIDFILE" ] && kill -0 "$(cat $VIDEO_PIDFILE)" 2>/dev/null; then
    # Stop video recording
    kill "$(cat $VIDEO_PIDFILE)" 2>/dev/null
    rm -f "$VIDEO_PIDFILE"

    # Stop audio recording
    if [ -f "$AUDIO_PIDFILE" ] && kill -0 "$(cat $AUDIO_PIDFILE)" 2>/dev/null; then
        kill "$(cat $AUDIO_PIDFILE)" 2>/dev/null
        rm -f "$AUDIO_PIDFILE"
    fi

    echo "stopped" >"$STATUSFILE"
    notify-send "Screen Recording" "Processing recording..." --icon=video-x-generic --urgency=normal

    # Merge recordings in background
    if [ -f "$VIDEO_FILE" ] && [ -f "$AUDIO_FILE" ]; then
        video_path=$(cat "$VIDEO_FILE")
        audio_path=$(cat "$AUDIO_FILE")
        rm -f "$VIDEO_FILE" "$AUDIO_FILE"

        # Run merge in background
        (merge_recordings "$video_path" "$audio_path") &
    fi
else
    # Start recording
    timestamp=$(date +%Y%m%d-%H%M%S)

    # Get the focused output (monitor)
    focused_output=$(get_focused_output)

    # Fallback to first available output if no focused output
    if [ -z "$focused_output" ] || [ "$focused_output" == "null" ]; then
        focused_output=$(hyprctl monitors -j | jq -r '.[0].name' 2>/dev/null)
    fi

    # Prepare filenames
    if [ -n "$focused_output" ] && [ "$focused_output" != "null" ]; then
        video_file="$VIDEOS_DIR/screenrecording-$focused_output-$timestamp.mp4"
        audio_file="$VIDEOS_DIR/screenrecording-$focused_output-$timestamp.wav"
        notify-send "Screen Recording" "Recording $focused_output with audio..." --icon=video-x-generic --urgency=normal
    else
        # Fallback to full screen recording
        video_file="$VIDEOS_DIR/screenrecording-$timestamp.mp4"
        audio_file="$VIDEOS_DIR/screenrecording-$timestamp.wav"
        notify-send "Screen Recording" "Recording all screens with audio..." --icon=video-x-generic --urgency=normal
    fi

    # Store filenames for later merging
    echo "$video_file" >"$VIDEO_FILE"
    echo "$audio_file" >"$AUDIO_FILE"

    # Start video recording (without system audio)
    if [ -n "$focused_output" ] && [ "$focused_output" != "null" ]; then
        wf-recorder \
            --output="$focused_output" \
            --file="$video_file" \
            --codec=libx264 \
            --pixel-format=yuv420p &
    else
        wf-recorder \
            --file="$video_file" \
            --codec=libx264 \
            --pixel-format=yuv420p &
    fi
    echo $! >"$VIDEO_PIDFILE"

    # Start audio recording from default input device
    pw-record --target @DEFAULT_SOURCE@ "$audio_file" &
    echo $! >"$AUDIO_PIDFILE"

    echo "recording" >"$STATUSFILE"
fi