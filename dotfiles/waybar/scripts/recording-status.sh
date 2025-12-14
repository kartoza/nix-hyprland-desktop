#!/usr/bin/env bash
# -*- coding: utf-8 -*-
# Waybar recording status widget script
# Part of Kartoza NixOS configuration

STATUSFILE="/tmp/wf-recorder.status"
PIDFILE="/tmp/wf-recorder.pid"

# Check if recording is active
if [ -f "$PIDFILE" ] && kill -0 "$(cat $PIDFILE)" 2>/dev/null; then
  # Recording is active - red glowing dot
  echo '{"text": "●", "class": "recording", "tooltip": "Click to stop recording (Ctrl+6)"}'
elif [ -f "$STATUSFILE" ] && [ "$(cat $STATUSFILE)" = "stopped" ]; then
  # Recently stopped - light gray dot
  echo '{"text": "●", "class": "stopped", "tooltip": "Click to start recording (Ctrl+6)"}'
else
  # Not recording - light gray dot
  echo '{"text": "●", "class": "idle", "tooltip": "Click to start recording (Ctrl+6)"}'
fi

