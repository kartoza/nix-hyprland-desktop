# Kartoza Wayfire Desktop Configuration

A standalone NixOS flake for configuring Wayfire desktop environment with Kartoza theming and customizations.

## Overview

This flake provides a complete Wayfire desktop environment configuration that can be imported into any NixOS flake. It includes:

- Wayfire compositor with plugins
- Waybar status bar with modular configuration
- Wofi application launcher
- Mako notification daemon
- Fuzzel and other utilities
- Complete theming and styling

## Usage

Add this flake as an input to your NixOS configuration:

```nix
{
  inputs = {
    wayfire-desktop.url = "github:kartoza/nix-wayfire-desktop";
    # ... other inputs
  };
}
```

Then import the module in your NixOS configuration:

```nix
{
  imports = [
    wayfire-desktop.nixosModules.default
    # ... other modules
  ];
}
```

## Dependencies

This module expects the importing flake to provide:
- `config.kartoza.theme.iconTheme.name` for GTK icon theme configuration

## Structure

- `modules/wayfire-desktop.nix` - Main NixOS module
- `dotfiles/` - Configuration files for Wayfire and related applications
- `resources/` - Images and other static resources

## Development

Enter development shell:
```bash
nix develop
```

Format code:
```bash
nix fmt
```