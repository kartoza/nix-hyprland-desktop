# Wayfire Configuration

This is a comprehensive Wayfire desktop configuration mirrored from the SwayFX setup.

## Features

### 🎨 Visual Effects

- **Blur**: Kawase blur on windows and panels (Waybar, Wofi, etc.)
- **Animations**: Smooth fade animations for window open/close
- **Wobbly Windows**: Fun window physics when moving windows
- **Cube Desktop**: 3D cube workspace switching (optional)
- **Transparency**: Alpha transparency control with `<Super><Alt>` + scroll

### 🪟 Window Management

- **Grid Tiling**: Snap windows to screen edges and grid positions
- **Focus follows mouse**: Windows are focused when hovered
- **Smart borders**: 3px colored borders showing focus state
- **Workspace Grid**: 3×3 workspace layout

### ⌨️ Key Bindings

#### Application Shortcuts

- `Super + Enter` - Terminal (Kitty)
- `Super + Space` - Application launcher (Wofi)
- `Super + E` - File manager (MC in Kitty)
- `Super + Q` - Close window
- `Super + .` - Emoji picker
- `Super + U` - Color picker

#### Window Management

- `Super + F` - Fullscreen
- `Super + M` - Maximize
- `Super + H/J/K/L` - Focus window (vim keys)
- `Super + Tab` - Fast window switcher
- `Alt + Tab` - Visual window switcher

#### Workspace Navigation

- `Super + 1-9` - Switch to workspace 1-9
- `Super + Shift + 1-9` - Move window to workspace
- `Super + Ctrl + Arrow Keys` - Navigate workspace grid
- `Super + Shift + Ctrl + Arrows` - Move window in workspace grid

#### Screen Management

- `Ctrl + Alt + L` - Lock screen
- `Ctrl + Alt + S` - Suspend
- `Super + Shift + R` - Reload Wayfire config

#### Screenshots

- `Print` - Screenshot full screen
- `Shift + Print` - Screenshot selection (interactive)

#### Media Keys

- `Volume Up/Down` - Volume control
- `Mute` - Toggle mute
- `Brightness Up/Down` - Screen brightness
- `Play/Pause` - Media playback control

### 🎯 Special Features

#### Expo Mode

Press and hold `Super` to see all workspaces in an overview. Click or press number keys to switch.

#### Cube Mode

- `Super + Ctrl + Left Mouse` - Activate cube rotation
- `Super + Ctrl + H/L` - Rotate cube left/right

#### Grid Snapping

Use numpad keys with `Super` to snap windows to different screen positions:

- `Super + KP7/8/9` - Top left/center/right
- `Super + KP4/5/6` - Middle left/center/right
- `Super + KP1/2/3` - Bottom left/center/right

### 🚀 Autostart Applications

The following applications start automatically:

- **Waybar** - Status bar with system information
- **Mako** - Notification daemon
- **Swaylock** - Screen locker
- **Swayidle** - Idle management (locks after 10 mins)
- **Swww** - Wallpaper setter
- **NetworkManager applet** - Network management
- **Blueman** - Bluetooth management
- **Avizo** - Volume/brightness on-screen display
- **Clipmenud** - Clipboard manager

### 🎨 Theming

- **Border Colors**:
  - Active: Orange (`#eb8444`)
  - Inactive: Gray (`#878B8D`)
- **Effects**: Blur, shadows, rounded corners
- **Font**: Nunito Regular 11pt
- **Scale**: 1.5x (adjust in `[output:*]` section)

## Configuration Files

- `wayfire.ini` - Main Wayfire configuration
- `scripts/get-default-browser.sh` - Browser detection helper
- `scripts/wofi-window-switcher.sh` - Visual window switcher

## Customization

### Change Wallpaper

Edit the wallpaper path in the `[autostart]` section:

```ini
wallpaper = swww init && swww img ~/Pictures/your-wallpaper.png
```

### Adjust Blur

Edit the `[blur]` section. Recommended settings:

- `method = kawase` (fast and good looking)
- `kawase_iterations = 2` (fewer = faster, more = smoother)
- `kawase_offset = 2.0` (higher = more blur)

### Disable Wobbly Windows

In `[core]` section, remove `wobbly \` from the plugins list.

### Change Workspace Grid

Edit in `[core]` section:

```ini
vwidth = 3  # Number of horizontal workspaces
vheight = 3 # Number of vertical workspaces
```

## Troubleshooting

### Waybar not showing

Check if waybar is running: `ps aux | grep waybar`
Restart it: `killall waybar && waybar &`

### Screen not locking

Ensure swayidle is running: `ps aux | grep swayidle`

### Blur not working

Check that blur is enabled in `[blur]` section and blur plugin is loaded in `[core]`.

### High CPU usage

Try reducing blur iterations or disabling wobbly windows.

## Integration with NixOS

This configuration is designed to work with the `wayfire-desktop.nix` profile which provides:

- Wayfire compositor
- All required Wayland tools
- PipeWire audio
- Network and Bluetooth management
- Screen sharing support
- GNOME Keyring integration

Simply import the profile in your host configuration:

```nix
imports = [
  ../../profiles/wayfire-desktop.nix
];
```
