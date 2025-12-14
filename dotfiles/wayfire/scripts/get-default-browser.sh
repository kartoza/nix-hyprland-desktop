#!/usr/bin/env bash
# Get the default browser set by Junction or fallback

# Check if Junction is installed
if command -v re.sonny.Junction &> /dev/null; then
    echo "re.sonny.Junction"
    exit 0
fi

# Fallback to firefox if available
if command -v firefox &> /dev/null; then
    echo "firefox"
    exit 0
fi

# Last resort: try chromium
if command -v chromium &> /dev/null; then
    echo "chromium"
    exit 0
fi

# Nothing found
echo "xdg-open"
