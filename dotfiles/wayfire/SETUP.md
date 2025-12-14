# Wayfire Desktop Profile - Creation Summary

## What Was Created

### 1. NixOS Profile Files

#### `/profiles/wayfire-desktop.nix`

Main profile wrapper that imports all necessary system modules:

- System configuration
- Power management
- Console applications
- Display server
- Desktop applications
- Wayfire desktop environment
- Host-specific desktop configuration

#### `/software/desktop-environments/wayfire-desktop.nix`

Complete Wayfire system configuration including:

- Wayfire compositor with plugins (wcm, wf-shell, wayfire-plugins-extra)
- Full Wayland app stack (Waybar, Wofi, Mako, Swaylock, etc.)
- PipeWire audio configuration
- Network Manager integration
- Bluetooth support (Blueman)
- Screen sharing (xdg-desktop-portal-wlr)
- GNOME Keyring for SSH/GPG
- Power profile management
- GTK theme integration
- Greetd login manager configured for Wayfire

### 2. User Configuration (Dotfiles)

#### `/dotfiles/wayfire/wayfire.ini`

Comprehensive Wayfire configuration (400+ lines) featuring:

**Core Settings:**

- 25+ plugins enabled (blur, animate, cube, expo, grid, etc.)
- 3×3 workspace grid layout
- XWayland support

**Visual Effects:**

- Kawase blur for windows and layers
- Smooth fade animations
- Wobbly windows physics
- 3D cube workspace switching
- Fisheye zoom effect
- Alpha transparency control

**Window Management:**

- Colored borders (orange for active, gray for inactive)
- Grid tiling with numpad shortcuts
- Focus follows mouse
- Client-side decorations

**Key Bindings:**

- Vim-style navigation (h/j/k/l)
- Workspace switching (1-9)
- Application launchers
- Media controls
- Screenshot tools
- Volume/brightness controls

**Autostart:**

- Waybar (status bar)
- Mako (notifications)
- Swaylock/Swayidle (screen locking)
- Swww (wallpaper)
- NetworkManager applet
- Blueman applet
- Avizo (OSD for volume/brightness)
- Polkit authentication agent

#### `/dotfiles/wayfire/scripts/`

Helper scripts:

- `get-default-browser.sh` - Detect default browser (Junction → Firefox → Chromium)
- `wofi-window-switcher.sh` - Visual window switcher using Wofi
- `setup-wallpaper.sh` - Wallpaper setup with Kartoza default fallback

#### `/dotfiles/wayfire/README.md`

Comprehensive documentation covering:

- Features overview
- Complete keybinding reference
- Customization guide
- Troubleshooting tips
- NixOS integration instructions

## Key Features

### 🎨 Visual Polish

- **Blur effects**: Kawase blur on panels and windows
- **Smooth animations**: Fade in/out transitions
- **Rounded corners**: 10px radius with smart corner radius
- **Shadows**: Enabled on windows with 10px blur radius
- **Wobbly windows**: Physics-based window movement

### ⌨️ Ergonomic Keybindings

- **Super + Enter**: Terminal
- **Super + Space**: App launcher
- **Super + Q**: Close window
- **Super + F**: Fullscreen
- **Super + 1-9**: Workspace switching
- **Alt + Tab**: Window switcher
- **Super (hold)**: Expo mode (workspace overview)

### 🪟 Smart Window Management

- **Grid tiling**: Numpad-based window snapping
- **Vim navigation**: h/j/k/l for focus
- **Workspace grid**: 3×3 layout with arrow key navigation
- **Focus follows mouse**: Intuitive window activation

### 🚀 Complete Desktop Experience

- Status bar with system info (Waybar)
- Notification system (Mako)
- Screen locking with idle timeout (Swaylock + Swayidle)
- Network and Bluetooth management
- Audio/video controls
- Screenshot tools
- Emoji picker
- Color picker

## Comparison with SwayFX

The Wayfire profile mirrors SwayFX design but uses Wayfire-specific features:

| Feature | SwayFX | Wayfire |
|---------|--------|---------|
| Compositor | Sway with effects | Wayfire |
| Configuration | Sway config syntax | INI format |
| Blur | SwayFX blur | Wayfire blur (Kawase/Gaussian/Box) |
| Animations | SwayFX animations | Wayfire animate plugin |
| Workspace Grid | Manual | Built-in 3×3 grid |
| 3D Effects | Limited | Full cube rotation |
| Tiling | i3-compatible | Grid-based + manual |
| Plugin System | Limited | Extensive (25+ plugins) |

## Usage

### To Use This Profile

1. **In your host configuration:**

   ```nix
   imports = [
     ../../profiles/wayfire-desktop.nix
   ];
   ```

2. **Deploy the configuration:**

   ```bash
   nix run .#<hostname>-deploy
   ```

3. **Or test in a VM:**

   ```bash
   nix run .#<hostname>-vm
   ```

### First Boot

1. Login via Greetd (tuigreet)
2. Wayfire will start automatically
3. Waybar, Mako, and other services launch on startup
4. Press `Super` (hold) to see the workspace overview
5. Press `Super + Space` for the application launcher

### Customization

Edit `~/.config/wayfire/wayfire.ini` to customize:

- Keybindings
- Visual effects
- Workspace layout
- Autostart applications
- Plugin configuration

Changes can be reloaded with `Super + Shift + R`.

## Files Created

```text
profiles/
  wayfire-desktop.nix                    # Profile wrapper

software/desktop-environments/
  wayfire-desktop.nix                    # System configuration

dotfiles/wayfire/
  wayfire.ini                            # Main config (400+ lines)
  README.md                              # User documentation
  scripts/
    get-default-browser.sh               # Browser detection
    wofi-window-switcher.sh              # Window switcher
    setup-wallpaper.sh                   # Wallpaper setup
```

## Next Steps

1. **Test the configuration** in a VM or on a test host
2. **Customize keybindings** in `wayfire.ini` to your preference
3. **Adjust visual effects** (blur amount, animation speed, etc.)
4. **Set your wallpaper** via the `[autostart]` section
5. **Configure Waybar** (uses same config as SwayFX)
6. **Enable/disable plugins** in the `[core]` section

Enjoy your new Wayfire desktop environment! 🎉
