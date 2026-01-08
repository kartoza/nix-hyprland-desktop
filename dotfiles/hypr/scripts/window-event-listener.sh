#!/usr/bin/env bash
# Event listener for Hyprland window events
# Calls unmaximize script when new windows open

handle() {
    case $1 in
        openwindow*)
            # When a new window opens, unmaximize any fullscreen/maximized windows
            /etc/xdg/hypr/scripts/unmaximize-on-new-window.sh
            ;;
    esac
}

# Listen to Hyprland events via socket
socat -U - UNIX-CONNECT:"$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | while read -r line; do
    handle "$line"
done
