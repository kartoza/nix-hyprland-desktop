#!/usr/bin/env bash
# Generate static keybindings list with emojis for fuzzel display
# This script parses Hyprland keybindings at build time to eliminate runtime latency

set -e

# Validate inputs
if [ $# -ne 2 ]; then
    echo "Usage: $0 <keybind_file> <output_file>"
    exit 1
fi

KEYBIND_FILE="$1"
OUTPUT_FILE="$2"

if [ ! -f "$KEYBIND_FILE" ]; then
    echo "Error: Keybind file not found: $KEYBIND_FILE"
    exit 1
fi

# Function to add emoji based on description keywords
add_emoji() {
  local desc="$1"
  local emoji=""

  # Match keywords and assign emojis
  if [[ "$desc" =~ terminal ]]; then emoji="💻"
  elif [[ "$desc" =~ browser ]]; then emoji="🌐"
  elif [[ "$desc" =~ filemanager|file ]]; then emoji="📁"
  elif [[ "$desc" =~ emoji ]]; then emoji="😀"
  elif [[ "$desc" =~ calculator ]]; then emoji="🔢"
  elif [[ "$desc" =~ focus|Move\ focus ]]; then emoji="🎯"
  elif [[ "$desc" =~ resize|width|height ]]; then emoji="↔️"
  elif [[ "$desc" =~ [Ss]wap ]]; then emoji="🔄"
  elif [[ "$desc" =~ workspace|Workspace ]]; then emoji="🏢"
  elif [[ "$desc" =~ window|Window ]]; then emoji="🪟"
  elif [[ "$desc" =~ [Kk]ill|[Qq]uit ]]; then emoji="❌"
  elif [[ "$desc" =~ fullscreen|[Mm]aximize ]]; then emoji="⛶"
  elif [[ "$desc" =~ floating ]]; then emoji="🎈"
  elif [[ "$desc" =~ screenshot ]]; then emoji="📸"
  elif [[ "$desc" =~ wallpaper ]]; then emoji="🖼️"
  elif [[ "$desc" =~ volume|Volume ]]; then emoji="🔊"
  elif [[ "$desc" =~ [Mm]ute ]]; then emoji="🔇"
  elif [[ "$desc" =~ brightness|Brightness ]]; then emoji="🔆"
  elif [[ "$desc" =~ audio|Audio|play|pause ]]; then emoji="🎵"
  elif [[ "$desc" =~ lock ]]; then emoji="🔒"
  elif [[ "$desc" =~ reload|Reload ]]; then emoji="🔄"
  elif [[ "$desc" =~ animation ]]; then emoji="✨"
  elif [[ "$desc" =~ zoom ]]; then emoji="🔍"
  elif [[ "$desc" =~ keybind|[Kk]eybind ]]; then emoji="⌨️"
  elif [[ "$desc" =~ clipboard ]]; then emoji="📋"
  elif [[ "$desc" =~ notification ]]; then emoji="🔔"
  elif [[ "$desc" =~ game ]]; then emoji="🎮"
  elif [[ "$desc" =~ power ]]; then emoji="⚡"
  elif [[ "$desc" =~ theme ]]; then emoji="🎨"
  fi

  echo "$emoji"
}

# Clear output file
> "$OUTPUT_FILE"

# Parse keybindings and generate static list
while IFS= read -r line; do
  # Skip comments, empty lines, and variable assignments
  [[ "$line" =~ ^[[:space:]]*# ]] && continue
  [[ "$line" =~ ^[[:space:]]*$ ]] && continue
  [[ "$line" =~ ^\$[a-zA-Z] ]] && continue
  [[ "$line" =~ ^source ]] && continue

  # Match bind lines with comments
  if [[ "$line" =~ ^bind[mle]*[[:space:]]*=[[:space:]]*([^#]+)#[[:space:]]*(.+)$ ]]; then
    bind_part="${BASH_REMATCH[1]}"
    description="${BASH_REMATCH[2]}"

    # Replace $mainMod with SUPER
    bind_part="${bind_part//\$mainMod/SUPER}"

    # Extract key combo and action by splitting on commas
    IFS=',' read -ra PARTS <<< "$bind_part"
    mods=$(echo "${PARTS[0]}" | xargs)     # Trim whitespace
    key=$(echo "${PARTS[1]}" | xargs)

    # Create readable key combination
    key_combo="$mods"
    if [[ -n "$key" ]]; then
      [[ -n "$key_combo" ]] && key_combo="$key_combo+"
      key_combo="$key_combo$key"
    fi

    # Add emoji to description
    emoji=$(add_emoji "$description")
    if [[ -n "$emoji" ]]; then
      description="$emoji $description"
    fi

    # Format for display (30 chars for key combo, rest for description)
    printf "%-30s %s\n" "$key_combo" "$description" >> "$OUTPUT_FILE"
  fi
done < "$KEYBIND_FILE"

# Report results
keybind_count=$(wc -l < "$OUTPUT_FILE")
echo "Generated $keybind_count keybindings to $OUTPUT_FILE"
