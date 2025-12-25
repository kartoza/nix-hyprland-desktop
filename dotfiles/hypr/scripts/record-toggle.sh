#!/usr/bin/env bash
# -*- coding: utf-8 -*-
# Screen recording toggle script for Wayfire with multi-monitor support
# Part of Kartoza NixOS configuration

PIDFILE="/tmp/wf-recorder.pid"
STATUSFILE="/tmp/wf-recorder.status"
VIDEOS_DIR="$HOME/Videos/Screencasts"

# Ensure videos directory exists
mkdir -p "$VIDEOS_DIR"

# Check if recording is active
if [ -f "$PIDFILE" ] && kill -0 "$(cat $PIDFILE)" 2>/dev/null; then
  # Stop recording
  kill "$(cat $PIDFILE)" 2>/dev/null
  rm -f "$PIDFILE"
  echo "stopped" >"$STATUSFILE"
  notify-send "Screen Recording" "Recording stopped" -i video-x-generic
else
  # Start recording on focused monitor
  timestamp=$(date +%Y%m%d-%H%M%S)

  # Get the focused output (monitor)
  focused_output=$(swaymsg -t get_workspaces | jq -r '.[] | select(.focused==true).output' 2>/dev/null)

  # Fallback to wayfire method if swaymsg doesn't work
  if [ -z "$focused_output" ] || [ "$focused_output" == "null" ]; then
    # Get all outputs and use the first one as fallback
    focused_output=$(wlr-randr | grep "^[A-Z]" | head -1 | cut -d' ' -f1)
  fi

  if [ -n "$focused_output" ]; then
    output_file="$VIDEOS_DIR/screenrecording-$focused_output-$timestamp.mp4"
    notify-send "Screen Recording" "Recording $focused_output..." -i video-x-generic

    # Start wf-recorder for specific output
    wf-recorder -o "$focused_output" -f "$output_file" &
  else
    # Fallback to full screen recording
    output_file="$VIDEOS_DIR/screenrecording-$timestamp.mp4"
    notify-send "Screen Recording" "Recording all screens..." -i video-x-generic

    # Start wf-recorder for all outputs
    wf-recorder -f "$output_file" &
  fi

  echo $! >"$PIDFILE"
  echo "recording" >"$STATUSFILE"
fi

