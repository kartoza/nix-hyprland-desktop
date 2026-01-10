#!/usr/bin/env bash
# -*- coding: utf-8 -*-
# Waybar recording status widget script
# Part of Kartoza NixOS configuration

STATUSFILE="/tmp/wl-screenrec.status"
VIDEO_PIDFILE="/tmp/wl-screenrec.pid"
AUDIO_PIDFILE="/tmp/pw-recorder.pid"
WEBCAM_PIDFILE="/tmp/webcam-recorder.pid"

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
  # Recording is active - red glowing dot
  echo '{"text": "●", "class": "recording", "tooltip": "Click to stop recording (Ctrl+6)"}'
elif [ -f "$STATUSFILE" ] && [ "$(cat $STATUSFILE)" = "stopped" ]; then
  # Recently stopped - light gray dot
  echo '{"text": "●", "class": "stopped", "tooltip": "Click to start recording (Ctrl+6)"}'
else
  # Not recording - light gray dot
  echo '{"text": "●", "class": "idle", "tooltip": "Click to start recording (Ctrl+6)"}'
fi

