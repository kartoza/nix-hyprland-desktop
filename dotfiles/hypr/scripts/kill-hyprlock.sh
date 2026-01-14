#!/usr/bin/env bash
# Comprehensive hyprlock cleanup script
# Handles process termination and cleanup of stale runtime files
# Based on hyprlock crash recovery procedures

echo "🔓 Hyprlock Cleanup Script"
echo "=========================="

# Try hyprctl dispatch exit first (recommended method)
echo "→ Attempting to exit hyprlock via hyprctl..."
if hyprctl dispatch exit 2>/dev/null; then
    echo "  ✓ Sent exit signal via hyprctl"
    sleep 1
else
    echo "  No active hyprlock session via hyprctl"
fi

# Kill hyprlock processes
echo "→ Checking for running hyprlock processes..."
if pgrep -x hyprlock > /dev/null; then
    echo "  Found hyprlock processes, attempting graceful shutdown..."
    pkill -15 hyprlock
    sleep 1

    # Force kill if still running
    if pgrep -x hyprlock > /dev/null; then
        echo "  Graceful shutdown failed, force killing..."
        pkill -9 hyprlock
        sleep 0.5
    fi

    if ! pgrep -x hyprlock > /dev/null; then
        echo "  ✓ Successfully killed hyprlock processes"
    else
        echo "  ✗ Failed to kill hyprlock processes"
    fi
else
    echo "  No running hyprlock processes found"
fi

# Check and clean hyprlock layers
echo "→ Checking for stuck hyprlock layers..."
if hyprctl layers | grep -q hyprlock; then
    echo "  Found hyprlock layers, these should clear after process cleanup"
    hyprctl layers | grep -A 5 hyprlock
else
    echo "  No hyprlock layers found"
fi

# Clean up runtime files
echo "→ Cleaning up runtime files..."
cleaned=0

# Remove hyprlock sockets in XDG_RUNTIME_DIR
if [ -n "$XDG_RUNTIME_DIR" ]; then
    for socket in "$XDG_RUNTIME_DIR"/hypr/*/hyprlock.sock; do
        if [ -e "$socket" ]; then
            rm -f "$socket"
            echo "  ✓ Removed socket: $socket"
            ((cleaned++))
        fi
    done

    # Remove lock files
    for lockfile in "$XDG_RUNTIME_DIR"/hypr/*/.hyprlock.lock; do
        if [ -e "$lockfile" ]; then
            rm -f "$lockfile"
            echo "  ✓ Removed lock file: $lockfile"
            ((cleaned++))
        fi
    done
fi

# Check common temporary locations
for tmp_lock in /tmp/.hyprlock-* /tmp/hyprlock-*; do
    if [ -e "$tmp_lock" ]; then
        rm -f "$tmp_lock"
        echo "  ✓ Removed temp file: $tmp_lock"
        ((cleaned++))
    fi
done

if [ $cleaned -eq 0 ]; then
    echo "  No stale runtime files found"
else
    echo "  ✓ Cleaned up $cleaned runtime file(s)"
fi

echo "=========================="
echo "✓ Cleanup complete!"
