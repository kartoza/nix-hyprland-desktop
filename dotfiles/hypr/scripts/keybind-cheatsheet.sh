#!/usr/bin/env bash
# Keybind cheat sheet using fuzzel
# Parses Hyprland keybindings and allows executing them

KEYBIND_FILE="/etc/xdg/hypr/conf/keybindings/default.conf"

# Parse keybindings and create fuzzel menu
parse_keybinds() {
    local keybinds=()
    local commands=()

    while IFS= read -r line; do
        # Skip comments, empty lines, and variable assignments
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ "$line" =~ ^[[:space:]]*$ ]] && continue
        [[ "$line" =~ ^\$[a-zA-Z] ]] && continue
        [[ "$line" =~ ^source ]] && continue

        # Match bind lines with comments
        if [[ "$line" =~ ^bind[mle]*[[:space:]]*=[[:space:]]*([^#]+)#[[:space:]]*(.+)$ ]]; then
            local bind_part="${BASH_REMATCH[1]}"
            local description="${BASH_REMATCH[2]}"

            # Parse the bind command
            # Format: MODIFIERS, KEY, ACTION, [PARAMS]
            if [[ "$bind_part" =~ \$mainMod ]]; then
                bind_part="${bind_part//\$mainMod/SUPER}"
            fi

            # Extract key combo and action by splitting on commas
            IFS=',' read -ra PARTS <<< "$bind_part"
            local mods=$(echo "${PARTS[0]}" | xargs)     # Trim whitespace
            local key=$(echo "${PARTS[1]}" | xargs)
            local action=$(echo "${PARTS[2]}" | xargs)
            # Join remaining parts for params (in case command has commas)
            local params=""
            if [[ ${#PARTS[@]} -gt 3 ]]; then
                params=$(echo "${PARTS[@]:3}" | xargs)
            fi

            # Create readable key combination
            local key_combo="$mods"
            if [[ -n "$key" ]]; then
                [[ -n "$key_combo" ]] && key_combo="$key_combo+"
                key_combo="$key_combo$key"
            fi

            # Format for display
            local display_line=$(printf "%-30s %s" "$key_combo" "$description")

            # Store for later execution
            keybinds+=("$display_line")

            # Build the command to execute
            local exec_cmd=""
            if [[ "$action" == "exec" ]]; then
                # Direct execution command
                exec_cmd="$params"
            elif [[ "$action" == "workspace" ]]; then
                exec_cmd="hyprctl dispatch workspace $params"
            elif [[ "$action" == "movetoworkspace" ]]; then
                exec_cmd="hyprctl dispatch movetoworkspace $params"
            elif [[ "$action" == "killactive" ]]; then
                exec_cmd="hyprctl dispatch killactive"
            elif [[ "$action" == "fullscreen" ]]; then
                exec_cmd="hyprctl dispatch fullscreen $params"
            elif [[ "$action" == "togglefloating" ]]; then
                exec_cmd="hyprctl dispatch togglefloating"
            elif [[ "$action" == "togglesplit" ]]; then
                exec_cmd="hyprctl dispatch togglesplit"
            elif [[ "$action" == "movefocus" ]]; then
                exec_cmd="hyprctl dispatch movefocus $params"
            elif [[ "$action" == "resizeactive" ]]; then
                exec_cmd="hyprctl dispatch resizeactive $params"
            elif [[ "$action" == "togglegroup" ]]; then
                exec_cmd="hyprctl dispatch togglegroup"
            elif [[ "$action" == "swapsplit" ]]; then
                exec_cmd="hyprctl dispatch swapsplit"
            elif [[ "$action" == "swapwindow" ]]; then
                exec_cmd="hyprctl dispatch swapwindow $params"
            elif [[ "$action" == "workspaceopt" ]]; then
                exec_cmd="hyprctl dispatch workspaceopt $params"
            else
                # Generic dispatch
                exec_cmd="hyprctl dispatch $action $params"
            fi

            commands+=("$exec_cmd")
        fi
    done < "$KEYBIND_FILE"

    # Display in fuzzel and get selection with Kartoza theming
    local selection=$(printf '%s\n' "${keybinds[@]}" | fuzzel --dmenu \
        --prompt="Kartoza Keybinds: " \
        --width=80 \
        --lines=25 \
        --font="JetBrains Mono:size=12" \
        --background-color=1a110fdd \
        --text-color=f1dfdaff \
        --match-color=ffb59dff \
        --selection-color=723520ff \
        --selection-text-color=ffdbd0ff \
        --border-color=ffb59dff \
        --border-width=2)

    # Find index of selection and execute corresponding command
    if [[ -n "$selection" ]]; then
        for i in "${!keybinds[@]}"; do
            if [[ "${keybinds[$i]}" == "$selection" ]]; then
                local cmd="${commands[$i]}"
                if [[ -n "$cmd" ]]; then
                    eval "$cmd" &
                fi
                break
            fi
        done
    fi
}

parse_keybinds
