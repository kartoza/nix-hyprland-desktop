# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Build and Format
- `nix develop` - Enter development shell with all dependencies
- `nix fmt` - Format all Nix files using nixfmt-rfc-style
- `nix flake check` - Check flake validity and formatting

### Testing Waybar Configuration
```bash
cd /path/to/nix-wayfire-desktop/dotfiles/waybar
./build-config.sh  # Rebuild modular waybar config
waybar -c config -s style.css --log-level debug  # Test waybar changes
```


## Architecture Overview

This is a **standalone NixOS flake** that provides a complete Wayfire desktop environment configuration. It's designed to be imported into any NixOS system as a module.

### Core Components

1. **Flake Structure** (`flake.nix`):
   - Exports `nixosModules.wayfire-desktop` for importing into NixOS configs
   - Provides development shell with formatting tools
   - Uses nixpkgs 25.05

2. **Main Module** (`modules/wayfire-desktop.nix`):
   - Comprehensive Wayfire desktop setup with all dependencies
   - Configures services: PipeWire, NetworkManager, gnome-keyring, greetd
   - Deploys dotfiles to `/etc/xdg` for system-wide availability with user override support
   - Includes keyring unlock utility and XDG config path resolution tools

3. **Dotfiles Structure** (`dotfiles/`):
   - **wayfire/**: Wayfire compositor config with plugins and scripts
   - **waybar/**: Modular status bar config system (see Waybar section below)
   - **wofi/**: Application launcher styling
   - **mako/**: Notification daemon theming (Kartoza branded) with custom notification sound
   - **fuzzel/**: Additional launcher utilities

### Waybar Modular Configuration System

The waybar config uses a **unique modular approach** for easier maintenance:

- `config.d/*.json` - Individual feature modules (base, widgets, custom modules)
- `build-config.sh` - Merges JSON files using `jq` into final `config`
- Numbering system: `00-` (base), `10-` (core modules), `90-` (UI widgets)
- Build process automatically excludes Sway-specific modules for Wayfire builds

### Theme Integration

- Expects `config.kartoza.theme.iconTheme.name` from importing flake (defaults to Papirus)
- Kartoza branding with custom logos and color schemes
- Orange accent color (`#eb8444`) for active window borders

### Keyboard Layout Configuration

The module provides configurable keyboard layouts with intelligent switching:

- **Default**: `["us", "pt"]` (US English, Portuguese)
- **Customizable**: Set any list of layouts via `keyboardLayouts` option
- **Smart Toggle**: Waybar script automatically reads layouts from Wayfire config
- **Alt+Shift**: Hardware toggle between configured layouts
- **Display Names**: Automatic conversion (us→EN, de→DE, fr→FR, pt→PT, etc.)

Example configuration:
```nix
kartoza.wayfire-desktop = {
  enable = true;
  keyboardLayouts = [ "us" "de" "fr" ];  # US, German, French
};
```

### Wallpaper Configuration

The module provides unified wallpaper management across desktop and lock screen:

- **Default**: `/etc/kartoza-wallpaper.png` (Kartoza branded wallpaper)
- **Configurable**: Set custom wallpaper path via `wallpaper` option
- **Unified**: Same wallpaper used for desktop background (swww) and lock screen (swaylock)
- **Styled Lock Screen**: Swaylock overlay with Kartoza colors, blur effects, clock, and indicators

Example configuration:
```nix
kartoza.wayfire-desktop = {
  enable = true;
  wallpaper = "/home/user/Pictures/custom-wallpaper.jpg";  # Custom wallpaper
};
```

### User Configuration Override Support

The module follows XDG Base Directory Specification for configuration management:

- **System configs**: `/etc/xdg/wayfire/`, `/etc/xdg/waybar/`, etc. (provided by module)
- **User overrides**: `~/.config/wayfire/`, `~/.config/waybar/`, etc. (user customizations)
- **Resolution order**: User configs in `~/.config/` take precedence over system configs in `/etc/xdg/`

#### XDG Config Tools

- `xdg-config-resolve` - Dynamic config path resolver for scripts and applications
- `xdg-config-path` - Simple path helper for shell scripts
- PATH includes both `~/.config/*/scripts` and `/etc/xdg/*/scripts` (user scripts first)

#### Overriding Configuration

Users can override any system configuration by copying files to their home directory:

```bash
# Override wayfire config
cp /etc/xdg/wayfire/wayfire.ini ~/.config/wayfire/

# Override waybar config
mkdir -p ~/.config/waybar
cp /etc/xdg/waybar/config ~/.config/waybar/
cp /etc/xdg/waybar/style.css ~/.config/waybar/

# Override individual waybar modules
mkdir -p ~/.config/waybar/config.d
cp -r /etc/xdg/waybar/config.d/* ~/.config/waybar/config.d/

# Override notification sound
mkdir -p ~/.config/mako/sounds
cp your-custom-sound.wav ~/.config/mako/sounds/notification.wav
```

All applications and scripts will automatically use the user's configuration if present.

### Key Scripts and Utilities

- `unlock-keyring` - GUI keyring unlock at login using zenity
- `wayfire/scripts/` - Window switching, browser detection, recording toggles
- `waybar/scripts/` - Status monitoring (temperature, power, notifications)

## Development Workflow

1. **Making Config Changes**: Edit files in `dotfiles/` subdirectories
2. **Waybar Changes**: Use modular system in `config.d/`, run `build-config.sh`
3. **Testing**: Use `nix develop` shell, test waybar with live reload
4. **Module Integration**: Changes are deployed via NixOS rebuild when module is imported

## Integration Notes

- Module configures complete Wayland environment (no X11 dependencies)
- Uses greetd for display management (no GDM/SDDM needed)
- Includes screen sharing support via xdg-desktop-portal-wlr
- PAM integration for keyring unlock on login and screen unlock
- Environment variables set for proper Wayland app compatibility