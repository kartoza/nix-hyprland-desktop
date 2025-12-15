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
   - Deploys dotfiles to `/etc/xdg` for system-wide availability
   - Includes keyring unlock utility

3. **Dotfiles Structure** (`dotfiles/`):
   - **wayfire/**: Wayfire compositor config with plugins and scripts
   - **waybar/**: Modular status bar config system (see Waybar section below)
   - **wofi/**: Application launcher styling
   - **mako/**: Notification daemon theming (Kartoza branded)
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