#!/usr/bin/env bash
# Setup wallpaper for Wayfire
# This script ensures there's a wallpaper available for swww

WALLPAPER_DIR="$HOME/Pictures"
WALLPAPER_NAME="sway-bg.png"
DEFAULT_WALLPAPER="/run/current-system/sw/share/backgrounds/kartoza-wallpaper.gif"

# Create Pictures directory if it doesn't exist
mkdir -p "$WALLPAPER_DIR"

# If wallpaper doesn't exist, try to link from system
if [ ! -f "$WALLPAPER_DIR/$WALLPAPER_NAME" ]; then
    if [ -f "$DEFAULT_WALLPAPER" ]; then
        ln -sf "$DEFAULT_WALLPAPER" "$WALLPAPER_DIR/$WALLPAPER_NAME"
        echo "Linked default Kartoza wallpaper"
    else
        # Create a simple colored background as fallback
        echo "No wallpaper found, please add one to $WALLPAPER_DIR/$WALLPAPER_NAME"
    fi
fi
