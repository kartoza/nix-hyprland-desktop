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
WEBCAM_PIDFILE="/tmp/webcam-recorder.pid"
STATUSFILE="/tmp/wf-recorder.status"
VIDEO_FILE="/tmp/wf-recorder.video"
AUDIO_FILE="/tmp/wf-recorder.audio"
WEBCAM_FILE="/tmp/wf-recorder.webcam"
VIDEOS_DIR="$HOME/Videos/Screencasts"

# Ensure videos directory exists
mkdir -p "$VIDEOS_DIR"

# Function to get focused monitor for Hyprland
get_focused_output() {
  # Try to get focused monitor from hyprctl
  hyprctl monitors -j | jq -r '.[] | select(.focused==true) | .name' 2>/dev/null
}

# Function to normalize audio and merge with video
merge_recordings() {
  local video_file="$1"
  local audio_file="$2"
  local webcam_file="$3"
  local output_file="${video_file%.mp4}-merged.mp4"
  local vertical_output_file="${video_file%.mp4}-vertical.mp4"

  # Wait a moment for files to be fully written
  sleep 2

  # Audio normalization filter:
  # - loudnorm: EBU R128 loudness normalization (broadcast standard)
  # - Target: -16 LUFS (good for screen recordings, clear but not too loud)
  # - Measured range: -1.5 LU (keeps dynamics)
  # - True peak: -2.0 dB (prevents clipping/distortion)
  local audio_filter="loudnorm=I=-16:TP=-2:LRA=11"

  notify-send "Screen Recording" "Processing audio and video..." --icon=video-x-generic --urgency=normal

  # Create screen + audio merged video (MAXIMUM QUALITY)
  # CRF 0 = completely lossless, preset veryslow = best quality/compression
  # AAC at 320k for highest audio quality
  if ffmpeg -y -i "$video_file" -i "$audio_file" \
    -af "$audio_filter" \
    -c:v libx264 -preset veryslow -crf 0 \
    -c:a aac -b:a 320k \
    -shortest \
    "$output_file" 2>&1 | grep -q "Output"; then

    # Get the output directory for the notification action
    output_dir=$(dirname "$output_file")
    filename=$(basename "$output_file")

    notify-send "Screen Recording Complete" \
      "$filename saved!" \
      --icon=video-x-generic \
      --urgency=normal

    # Create vertical video with webcam if available
    if [ -f "$webcam_file" ] && [ -s "$webcam_file" ]; then
      notify-send "Screen Recording" "Creating vertical video with webcam..." --icon=video-x-generic --urgency=normal

      # Get screen video dimensions
      screen_width=$(ffprobe -v error -select_streams v:0 -show_entries stream=width -of csv=p=0 "$video_file")
      screen_height=$(ffprobe -v error -select_streams v:0 -show_entries stream=height -of csv=p=0 "$video_file")

      # Get webcam video dimensions
      webcam_width=$(ffprobe -v error -select_streams v:0 -show_entries stream=width -of csv=p=0 "$webcam_file")
      webcam_height_orig=$(ffprobe -v error -select_streams v:0 -show_entries stream=height -of csv=p=0 "$webcam_file")

      # Calculate webcam height to match screen width (maintain aspect ratio)
      if [ "$webcam_width" -gt 0 ]; then
        webcam_height=$((screen_width * webcam_height_orig / webcam_width))
      else
        # Fallback if we can't get dimensions
        webcam_height=$((screen_width * 3 / 4))
      fi

      # Create vertical video: screen on top, webcam below
      # Using MAXIMUM QUALITY: CRF 0 (lossless), veryslow preset
      if ffmpeg -y -i "$video_file" -i "$webcam_file" -i "$audio_file" \
        -filter_complex "\
          [0:v]scale=${screen_width}:${screen_height}:flags=lanczos[screen]; \
          [1:v]scale=${screen_width}:${webcam_height}:flags=lanczos[webcam]; \
          [screen][webcam]vstack=inputs=2[outv]" \
        -map "[outv]" -map 2:a \
        -af "$audio_filter" \
        -c:v libx264 -preset veryslow -crf 0 -pix_fmt yuv420p \
        -c:a aac -b:a 320k \
        -shortest \
        "$vertical_output_file" 2>&1 | grep -q "Output"; then

        vertical_filename=$(basename "$vertical_output_file")
        notify-send "Vertical Recording Complete" \
          "$vertical_filename saved!" \
          --icon=video-x-generic \
          --urgency=normal
      else
        notify-send "Vertical Video Warning" \
          "Failed to create vertical video. Screen recording saved." \
          --icon=dialog-warning \
          --urgency=normal
      fi
    fi

    # Clean up temporary tracking files
    rm -f "$VIDEO_FILE" "$AUDIO_FILE" "$WEBCAM_FILE"

  else
    notify-send "Screen Recording Error" \
      "Failed to merge recordings.\nFiles saved separately in Videos/Screencasts" \
      --icon=dialog-error \
      --urgency=critical
  fi
}

# Check if any recording is active
is_recording=false

# Check screen recording
if [ -f "$VIDEO_PIDFILE" ] && kill -0 "$(cat $VIDEO_PIDFILE)" 2>/dev/null; then
  is_recording=true
fi

# Check webcam recording
if [ -f "$WEBCAM_PIDFILE" ] && kill -0 "$(cat $WEBCAM_PIDFILE)" 2>/dev/null; then
  is_recording=true
fi

# Check audio recording
if [ -f "$AUDIO_PIDFILE" ] && kill -0 "$(cat $AUDIO_PIDFILE)" 2>/dev/null; then
  is_recording=true
fi

if [ "$is_recording" = true ]; then
  # Stop video recording
  if [ -f "$VIDEO_PIDFILE" ] && kill -0 "$(cat $VIDEO_PIDFILE)" 2>/dev/null; then
    kill "$(cat $VIDEO_PIDFILE)" 2>/dev/null
    rm -f "$VIDEO_PIDFILE"
  fi

  # Stop audio recording
  if [ -f "$AUDIO_PIDFILE" ] && kill -0 "$(cat $AUDIO_PIDFILE)" 2>/dev/null; then
    kill "$(cat $AUDIO_PIDFILE)" 2>/dev/null
    rm -f "$AUDIO_PIDFILE"
  fi

  # Stop webcam recording if active
  if [ -f "$WEBCAM_PIDFILE" ] && kill -0 "$(cat $WEBCAM_PIDFILE)" 2>/dev/null; then
    kill "$(cat $WEBCAM_PIDFILE)" 2>/dev/null
    rm -f "$WEBCAM_PIDFILE"
  fi

  echo "stopped" >"$STATUSFILE"
  notify-send "Screen Recording" "Processing recording..." --icon=video-x-generic --urgency=normal

  # Merge recordings in background
  if [ -f "$VIDEO_FILE" ] && [ -f "$AUDIO_FILE" ]; then
    video_path=$(cat "$VIDEO_FILE")
    audio_path=$(cat "$AUDIO_FILE")
    webcam_path=$(cat "$WEBCAM_FILE" 2>/dev/null || echo "")
    # Run merge in background
    (merge_recordings "$video_path" "$audio_path" "$webcam_path") &
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
    webcam_file="$VIDEOS_DIR/screenrecording-webcam-$focused_output-$timestamp.mp4"
    notify-send "Screen Recording" "Recording $focused_output with audio..." --icon=video-x-generic --urgency=normal
  else
    # Fallback to full screen recording
    video_file="$VIDEOS_DIR/screenrecording-$timestamp.mp4"
    audio_file="$VIDEOS_DIR/screenrecording-$timestamp.wav"
    webcam_file="$VIDEOS_DIR/screenrecording-webcam-$timestamp.mp4"
    notify-send "Screen Recording" "Recording all screens with audio..." --icon=video-x-generic --urgency=normal
  fi

  # Store filenames for later merging
  echo "$video_file" >"$VIDEO_FILE"
  echo "$audio_file" >"$AUDIO_FILE"
  echo "$webcam_file" >"$WEBCAM_FILE"

  # Start video recording (MAXIMUM QUALITY - lossless)
  # CRF 0 = completely lossless
  # preset=veryslow = best compression with highest quality
  if [ -n "$focused_output" ] && [ "$focused_output" != "null" ]; then
    wf-recorder \
      --output="$focused_output" \
      --file="$video_file" \
      --codec=libx264 \
      --codec-param="preset=veryslow,crf=0" \
      --pixel-format=yuv420p &
  else
    wf-recorder \
      --file="$video_file" \
      --codec=libx264 \
      --codec-param="preset=veryslow,crf=0" \
      --pixel-format=yuv420p &
  fi
  echo $! >"$VIDEO_PIDFILE"

  # Start audio recording from default input device (WAV for lossless quality)
  pw-record --target @DEFAULT_SOURCE@ "$audio_file" &
  echo $! >"$AUDIO_PIDFILE"

  # Start recording the webcam if available
  if command -v ffmpeg >/dev/null 2>&1; then
    # Find first available video device
    webcam_device=""
    for device in video0 video1 video2 video3; do
      if [ -c "/dev/$device" ]; then
        webcam_device="$device"
        break
      fi
    done

    if [ -n "$webcam_device" ]; then
      # Record webcam at native quality (MAXIMUM QUALITY - lossless)
      # Using preset=veryslow and crf=0 for lossless capture
      ffmpeg -f v4l2 -i "/dev/$webcam_device" \
        -c:v libx264 -preset veryslow -crf 0 -pix_fmt yuv420p \
        "$webcam_file" >/dev/null 2>&1 &

      webcam_pid=$!
      if [ $webcam_pid -gt 0 ]; then
        echo $webcam_pid >"$WEBCAM_PIDFILE"
        notify-send "Webcam Recording" "Recording webcam on /dev/$webcam_device (lossless)" --icon=camera-web --urgency=low
      fi
    else
      notify-send "Webcam Recording" "No webcam detected" --icon=dialog-information --urgency=low
    fi
  fi

  echo "recording" >"$STATUSFILE"
fi

