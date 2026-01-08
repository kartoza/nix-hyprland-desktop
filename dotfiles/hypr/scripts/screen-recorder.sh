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

# Function to get monitor where mouse cursor is located
get_mouse_monitor() {
  # Get current cursor position
  local cursor_pos=$(hyprctl cursorpos 2>/dev/null)
  if [ -z "$cursor_pos" ]; then
    # Fallback to focused monitor if cursor position unavailable
    hyprctl monitors -j | jq -r '.[] | select(.focused==true) | .name' 2>/dev/null
    return
  fi

  # Parse cursor position (format: "x, y")
  local cursor_x=$(echo "$cursor_pos" | cut -d',' -f1 | tr -d ' ')
  local cursor_y=$(echo "$cursor_pos" | cut -d',' -f2 | tr -d ' ')

  # Get monitor information and find which one contains the cursor
  hyprctl monitors -j | jq -r --argjson cx "$cursor_x" --argjson cy "$cursor_y" '
    .[] |
    select(
      $cx >= .x and
      $cx < (.x + .width) and
      $cy >= .y and
      $cy < (.y + .height)
    ) |
    .name
  ' 2>/dev/null | head -n1
}

# Function to normalize audio and merge with video
merge_recordings() {
  local video_file="$1"
  local audio_file="$2"
  local webcam_file="$3"
  local output_file="${video_file%.mp4}-merged.mp4"
  local vertical_output_file="${video_file%.mp4}-vertical.mp4"
  local normalized_audio="${audio_file%.wav}-normalized.wav"

  # Wait a moment for files to be fully written
  sleep 2

  notify-send "Screen Recording" "Removing background noise..." --icon=video-x-generic --urgency=normal

  # Step 1: Remove background noise
  # - highpass: Remove low-frequency rumble (< 200 Hz)
  # - afftdn: FFT-based denoiser for constant background noise
  #   - nf=-25: Noise floor (adjust based on noise level)
  #   - tn=1: Track noise (adapts to changing noise)
  local denoised_audio="${audio_file%.wav}-denoised.wav"

  if ffmpeg -y -i "$audio_file" \
    -af "highpass=f=200,afftdn=nf=-25:tn=1" \
    -c:a pcm_s16le \
    "$denoised_audio" 2>&1 | grep -q "Output"; then

    # Use denoised audio for normalization
    local audio_for_norm="$denoised_audio"
  else
    notify-send "Noise Reduction Warning" "Skipping noise reduction" --icon=dialog-warning --urgency=low
    local audio_for_norm="$audio_file"
  fi

  notify-send "Screen Recording" "Analyzing audio levels..." --icon=video-x-generic --urgency=normal

  # Step 2: TWO-PASS LOUDNORM for maximum quality without clipping
  # Pass 1: Measure the audio levels
  local loudnorm_stats=$(ffmpeg -i "$audio_for_norm" -af loudnorm=I=-14:TP=-1.5:LRA=11:print_format=json -f null - 2>&1 | tail -n 12)

  # Extract measured values from JSON output
  local measured_I=$(echo "$loudnorm_stats" | grep input_i | cut -d'"' -f4 | sed 's/[^0-9.-]//g')
  local measured_TP=$(echo "$loudnorm_stats" | grep input_tp | cut -d'"' -f4 | sed 's/[^0-9.-]//g')
  local measured_LRA=$(echo "$loudnorm_stats" | grep input_lra | cut -d'"' -f4 | sed 's/[^0-9.-]//g')
  local measured_thresh=$(echo "$loudnorm_stats" | grep input_thresh | cut -d'"' -f4 | sed 's/[^0-9.-]//g')

  # Pass 2: Create normalized audio file (preserving original)
  # Target: -14 LUFS (louder than broadcast, perfect for screen recordings)
  # True peak: -1.5 dB (prevents clipping while maximizing volume)
  # LRA: 11 (preserves dynamic range)
  notify-send "Screen Recording" "Normalizing audio..." --icon=video-x-generic --urgency=normal

  if ffmpeg -y -i "$audio_for_norm" \
    -af "loudnorm=I=-14:TP=-1.5:LRA=11:measured_I=${measured_I}:measured_TP=${measured_TP}:measured_LRA=${measured_LRA}:measured_thresh=${measured_thresh}:linear=true:print_format=summary" \
    -c:a pcm_s16le \
    "$normalized_audio" 2>&1 | grep -q "Output"; then

    notify-send "Screen Recording" "Merging video and audio..." --icon=video-x-generic --urgency=normal
  else
    notify-send "Audio Normalization Warning" "Using original audio" --icon=dialog-warning --urgency=normal
    normalized_audio="$audio_file"
  fi

  # Create screen + audio merged video (MAXIMUM QUALITY)
  # CRF 0 = completely lossless, preset veryslow = best quality/compression
  # AAC at 320k for highest audio quality
  if ffmpeg -y -i "$video_file" -i "$normalized_audio" \
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
      if ffmpeg -y -i "$video_file" -i "$webcam_file" -i "$normalized_audio" \
        -filter_complex "\
          [0:v]scale=${screen_width}:${screen_height}:flags=lanczos[screen]; \
          [1:v]scale=${screen_width}:${webcam_height}:flags=lanczos[webcam]; \
          [screen][webcam]vstack=inputs=2[outv]" \
        -map "[outv]" -map 2:a \
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
  # Stop video recording with SIGINT (wf-recorder needs this to properly finalize)
  if [ -f "$VIDEO_PIDFILE" ] && kill -0 "$(cat $VIDEO_PIDFILE)" 2>/dev/null; then
    video_pid=$(cat $VIDEO_PIDFILE)
    kill -INT "$video_pid" 2>/dev/null
    # Wait for wf-recorder to finalize the file (max 5 seconds)
    for i in {1..10}; do
      kill -0 "$video_pid" 2>/dev/null || break
      sleep 0.5
    done
    rm -f "$VIDEO_PIDFILE"
  fi

  # Stop audio recording with SIGINT
  if [ -f "$AUDIO_PIDFILE" ] && kill -0 "$(cat $AUDIO_PIDFILE)" 2>/dev/null; then
    audio_pid=$(cat $AUDIO_PIDFILE)
    kill -INT "$audio_pid" 2>/dev/null
    # Wait for pw-record to finalize the file (max 5 seconds)
    for i in {1..10}; do
      kill -0 "$audio_pid" 2>/dev/null || break
      sleep 0.5
    done
    rm -f "$AUDIO_PIDFILE"
  fi

  # Stop webcam recording if active with SIGINT
  if [ -f "$WEBCAM_PIDFILE" ] && kill -0 "$(cat $WEBCAM_PIDFILE)" 2>/dev/null; then
    webcam_pid=$(cat $WEBCAM_PIDFILE)
    kill -INT "$webcam_pid" 2>/dev/null
    # Wait for ffmpeg to finalize the file (max 5 seconds)
    for i in {1..10}; do
      kill -0 "$webcam_pid" 2>/dev/null || break
      sleep 0.5
    done
    rm -f "$WEBCAM_PIDFILE"
  fi

  echo "stopped" >"$STATUSFILE"
  notify-send "Screen Recording" "Processing recording..." --icon=video-x-generic --urgency=normal

  # Additional wait to ensure all files are fully written and flushed to disk
  sleep 1

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

  # Get the monitor where mouse cursor is located
  focused_output=$(get_mouse_monitor)

  # Fallback to first available output if no mouse monitor detected
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
  # No audio parameter - we handle audio separately with pw-record
  if [ -n "$focused_output" ] && [ "$focused_output" != "null" ]; then
    wf-recorder \
      --output="$focused_output" \
      --file="$video_file" \
      --codec=libx264 \
      --codec-param=preset=veryslow \
      --codec-param=crf=0 \
      --pixel-format=yuv420p \
      >/tmp/wf-recorder-error.log 2>&1 &
    video_pid=$!
  else
    wf-recorder \
      --file="$video_file" \
      --codec=libx264 \
      --codec-param=preset=veryslow \
      --codec-param=crf=0 \
      --pixel-format=yuv420p \
      >/tmp/wf-recorder-error.log 2>&1 &
    video_pid=$!
  fi

  # Save PID and verify wf-recorder started
  echo $video_pid >"$VIDEO_PIDFILE"

  # Wait a moment and check if wf-recorder is still running
  sleep 1
  if ! kill -0 "$video_pid" 2>/dev/null; then
    notify-send "Screen Recording Error" \
      "wf-recorder failed to start. Check /tmp/wf-recorder-error.log for details." \
      --icon=dialog-error \
      --urgency=critical
    rm -f "$VIDEO_PIDFILE"
    exit 1
  fi

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
      # Record webcam optimized for REAL-TIME capture (no latency, no stuttering)
      # - input_format=mjpeg: Use hardware MJPEG for lower CPU usage
      # - framerate=60: Silky smooth 60fps capture - eliminates motion blur
      # - preset=ultrafast: Minimal encoding latency for real-time
      # - tune=zerolatency: Optimize for zero-latency encoding
      # - threads=0: Use all available CPU cores
      # - crf=18: Near-lossless quality (lower = better, 18 is visually lossless)
      # - bf=0: No B-frames for lower latency
      # - g=120: Keyframe every 2 seconds at 60fps
      # - x264opts: no-scenecut for consistent latency
      ffmpeg -f v4l2 -input_format mjpeg -framerate 60 -video_size 1920x1080 -i "/dev/$webcam_device" \
        -c:v libx264 -preset ultrafast -tune zerolatency \
        -crf 18 -pix_fmt yuv420p \
        -bf 0 -g 120 -threads 0 \
        -x264opts no-scenecut \
        "$webcam_file" >/dev/null 2>&1 &

      webcam_pid=$!
      if [ $webcam_pid -gt 0 ]; then
        echo $webcam_pid >"$WEBCAM_PIDFILE"
        notify-send "Webcam Recording" "Recording webcam on /dev/$webcam_device (60fps real-time)" --icon=camera-web --urgency=low
      fi
    else
      notify-send "Webcam Recording" "No webcam detected" --icon=dialog-information --urgency=low
    fi
  fi

  echo "recording" >"$STATUSFILE"
fi

