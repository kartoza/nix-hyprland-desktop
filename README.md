# Kartoza Hyprland Desktop Configuration

A standalone NixOS flake for configuring Hyprland desktop environment with Kartoza theming and customizations.

## Overview

This flake provides a complete Hyprland desktop environment configuration that can be imported into any NixOS flake. It includes:

- Hyprland compositor with window animations and effects
- Waybar status bar with modular configuration and **working taskbar**
- **Workspace Management**: Named workspaces with fuzzel-based switcher
- Nwggrid and nwgpanel application launcher
- **Mako notification daemon** with Kartoza theming and custom sound
- Fuzzel and other utilities
- Complete theming and styling
- GNOME Keyring integration with SSH and GPG support
- **Floating windows by default** with optional tiling mode
- **Secure clipboard management** with clipse encryption and fuzzel interface
- **Desktop zoom functionality** for accessibility and presentations 
- **Screen recording** with multi-monitor support and audio
- **Emoji picker** with fuzzel search interface
- **On-screen key display** for tutorials and presentations

## Usage

### Step 1: Add Flake Input

Add this flake as an input to your NixOS configuration:

```nix
{
  inputs = {
    hyprland-desktop.url = "github:kartoza/nix-hyprland-desktop";
    # ... other inputs
  };
}
```

### Step 2: Import and Enable Module

Import the module and enable it in your NixOS configuration:

```nix
{
  imports = [
    hyprland-desktop.nixosModules.default
    # ... other modules
  ];

  # Enable Kartoza Hyprland Desktop with one line!
  kartoza.hyprland-desktop.enable = true;
}
```

### Step 3: Configure Display Manager (CRITICAL)

**IMPORTANT**: You must configure your display manager to start Hyprland with the correct configuration file. The module configures greetd as the display manager, but you need to set the initial session command in your user configuration:

```nix
{
  # Configure greetd to auto-login with Hyprland
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd 'Hyprland --config /etc/xdg/hypr/hyprland.conf'";
        user = "greeter";
      };
      
      # Optional: Auto-login for a specific user
      initial_session = {
        command = "Hyprland --config /etc/xdg/hypr/hyprland.conf";
        user = "your-username";  # Replace with your actual username
      };
    };
  };
}
```

**Critical Parameter**:
- `--config /etc/xdg/hypr/hyprland.conf` - Ensures Hyprland uses the module's configuration

Without this parameter, Hyprland will use default configs and the desktop environment may not work correctly.

### Step 4: Rebuild System

After configuration, rebuild your system:

```bash
sudo nixos-rebuild switch --flake .#your-hostname
```

### Configuration Options

```nix
{
  kartoza.hyprland-desktop = {
    enable = true;
    iconTheme = "Papirus";              # Icon theme (default: "Papirus")
    gtkTheme = "Adwaita";               # GTK theme (default: "Adwaita")
    darkTheme = true;                   # Use dark theme (default: true)
    fractionalScaling = 1.25;           # Default scaling factor (default: 1.0)
    qtTheme = "gnome";                  # Qt platform theme (default: "gnome")
    cursorTheme = "Vanilla-DMZ";        # Cursor theme (default: "Vanilla-DMZ")
    cursorSize = 24;                    # Cursor size in pixels (default: 24)
    
    # Per-display scaling overrides
    displayScaling = {
      "eDP-1" = 1.5;    # Laptop screen at 150%
      "DP-9" = 1.0;     # External monitor at 100%
    };
    
    # Keyboard layout configuration
    keyboardLayouts = [ "us" "pt" ];       # Default: US English, Portuguese
    # keyboardLayouts = [ "us" "de" "fr" ]; # Example: US, German, French
    # keyboardLayouts = [ "us" "es" ];      # Example: US, Spanish
    
    # Wallpaper configuration
    wallpaper = "/etc/kartoza-wallpaper.png";          # Default: Kartoza wallpaper
    # wallpaper = "/home/user/Pictures/my-wallpaper.jpg"; # Example: Custom wallpaper
  };
}
```

## Keyboard Layout Configuration

The module provides intelligent keyboard layout management with configurable options:

### Features

- **Multiple Layout Support**: Configure any number of keyboard layouts
- **Smart Toggle**: Alt+Shift switches between layouts automatically
- **Waybar Integration**: Shows current layout with proper display names
- **Auto-Detection**: Waybar script reads layouts from Hyprland configuration
- **Display Name Mapping**: Converts layout codes to readable names (us→EN, de→DE, fr→FR, pt→PT, etc.)

### Configuration Examples

```nix
# Default configuration (US English + Portuguese)
kartoza.hyprland-desktop = {
  enable = true;
  keyboardLayouts = [ "us" "pt" ];
};

# European configuration (US English + German + French)
kartoza.hyprland-desktop = {
  enable = true;
  keyboardLayouts = [ "us" "de" "fr" ];
};

# Spanish configuration
kartoza.hyprland-desktop = {
  enable = true;
  keyboardLayouts = [ "us" "es" ];
};

# Multi-language setup
kartoza.hyprland-desktop = {
  enable = true;
  keyboardLayouts = [ "us" "de" "fr" "it" "pt" ];
};
```

### How It Works

1. **Module Configuration**: The `keyboardLayouts` option generates the Hyprland configuration
2. **Hyprland Setup**: Layouts are configured in `kb_layout` with Alt+Shift toggle (`grp:alt_shift_toggle`)
3. **Waybar Display**: The keyboard layout script reads the Hyprland config and shows the current layout
4. **Toggle Methods**: 
   - **Hardware**: Press Alt+Shift to cycle through layouts
   - **GUI**: Click the keyboard layout widget in Waybar

### Supported Layout Codes

The module supports standard XKB layout codes:

| Code | Language | Display Name |
|------|----------|--------------|
| `us` | US English | EN |
| `pt` | Portuguese | PT |
| `de` | German | DE |
| `fr` | French | FR |
| `es` | Spanish | ES |
| `it` | Italian | IT |
| `ru` | Russian | RU |
| `pl` | Polish | PL |
| `nl` | Dutch | NL |
| `se` | Swedish | SE |
| `no` | Norwegian | NO |
| `dk` | Danish | DK |
| `fi` | Finnish | FI |

For other layouts, the script will display the uppercase layout code (e.g., `cz` → `CZ`).

### Testing in VM

The test VM is configured with US, German, and French layouts to demonstrate the feature:

```bash
./run-vm.sh
# In the VM: Press Alt+Shift to cycle between US, German, French layouts
# Check the Waybar keyboard layout widget for current layout display
```

## Wallpaper Configuration

The module provides unified wallpaper management for both desktop background and lock screen:

### Features

- **Unified Wallpaper**: Same image used for desktop background and swaylock
- **Configurable Path**: Override with any image file path
- **Lock Screen Styling**: Swaylock displays wallpaper with beautiful Kartoza-themed overlay
- **Effects**: Lock screen includes blur, vignette, clock, and caps lock indicator
- **Smart Scaling**: Automatically scales wallpaper to fit screen resolution

### Configuration Examples

```nix
# Default configuration (uses Kartoza wallpaper)
kartoza.hyprland-desktop = {
  enable = true;
  wallpaper = "/etc/kartoza-wallpaper.png"; # Default
};

# Custom wallpaper configuration
kartoza.hyprland-desktop = {
  enable = true;
  wallpaper = "/home/user/Pictures/my-wallpaper.jpg";
};

# Network wallpaper (downloaded separately)
kartoza.hyprland-desktop = {
  enable = true;
  wallpaper = "/usr/share/backgrounds/nature.jpg";
};
```

### Supported Image Formats

Swaylock and swww support common image formats:
- PNG (.png)
- JPEG (.jpg, .jpeg) 
- BMP (.bmp)
- WEBP (.webp)

### Lock Screen Features

The swaylock configuration includes:
- **Clock Display**: Shows current time and date
- **Keyboard Layout**: Shows current layout indicator
- **Kartoza Theme**: Blue and orange color scheme matching desktop
- **Visual Effects**: Blur effect on wallpaper, vignette overlay
- **Security Features**: Caps lock indicator, wrong password feedback
- **Accessibility**: Large, readable fonts and clear visual indicators

### Testing Wallpaper

To test the wallpaper configuration:

```bash
# Test desktop wallpaper change
swww img /path/to/your/wallpaper.jpg

# Test lock screen wallpaper (Ctrl+Alt+L to lock)
swaylock -c /etc/xdg/swaylock/config
```

## Notification Daemon

The module uses **Mako** as the notification daemon, providing lightweight desktop notifications with Kartoza theming.

### Features

- Lightweight and minimal resource usage
- Simple popup notifications with action button support
- Custom Kartoza branding and color scheme
- Custom notification sound
- Configuration via XDG config directories

### Customizing Notifications

Mako configuration can be customized by copying the system config to your home directory:

```bash
# Override Mako configuration
cp /etc/xdg/mako/kartoza ~/.config/mako/config
# Edit ~/.config/mako/config

# Override notification sound
mkdir -p ~/.config/mako/sounds
cp your-custom-sound.wav ~/.config/mako/sounds/notification.wav
```

## Workspace Management

The module provides a comprehensive workspace management system with named workspaces and fuzzel-based switching.

### Features

- **Named Workspaces**: Each workspace has a meaningful name (Browser, Chat, Terminal, etc.)
- **Fuzzel Integration**: Beautiful graphical workspace selector with fuzzel
- **Waybar Widget**: Clickable workspace indicator in status bar with **working taskbar**
- **Window Management**: Click taskbar icons to focus windows, middle-click to close
- **Keyboard Shortcuts**: Multiple ways to switch workspaces
- **Change Tracking**: Automatic logging when switching workspaces using `hyprctl`
- **User Customizable**: Override workspace names easily
- **Floating Mode**: Windows spawn in floating mode by default (Super+F to toggle tiling)

### Default Workspace Layout

The system provides a 3×3 workspace grid with meaningful default names:

```
┌─────────────┬─────────────┬─────────────┐
│ 1: Browser  │ 2: Chat     │ 3: Terminal │
├─────────────┼─────────────┼─────────────┤
│ 4: Project1 │ 5: Project2 │ 6: Media    │
├─────────────┼─────────────┼─────────────┤
│ 7: Documents│ 8: Games    │ 9: System   │
└─────────────┴─────────────┴─────────────┘
```

### Usage

#### Keyboard Shortcuts

- **`Super + S`** - Open fuzzel workspace switcher (primary method)
- **`Super + 1-9`** - Switch directly to workspace 1-9
- **`Super + Shift + 1-9`** - Move current window to workspace 1-9
- **`Ctrl + Super + Arrow Keys`** - Navigate workspace grid
- **`Super + Shift + Ctrl + Arrows`** - Move window in workspace grid

#### Waybar Integration

The waybar displays a workspace widget showing:
- Current workspace number and name (e.g., "2: Chat")
- Click to open fuzzel workspace switcher
- Auto-updates when workspace changes
- Styled with Kartoza theme colors

#### Managing Workspace Names

```bash
# Show current workspace
workspace-names.sh current

# List all workspace names  
workspace-names.sh list

# Rename a workspace
workspace-names.sh set 1 "Web Browser"
workspace-names.sh set 4 "Development"

# Get specific workspace name
workspace-names.sh get 2
```

### Customization

#### Custom Workspace Names

Override the default workspace names by copying and editing the configuration:

```bash
# Copy system config to user directory
mkdir -p ~/.config/hypr
cp /etc/xdg/hypr/workspace-names.conf ~/.config/hypr/

# Edit workspace names (format: workspace_number=workspace_name)
cat >> ~/.config/hypr/workspace-names.conf << EOF
0=My Browser
1=Slack & Teams
2=Terminal Work
3=Main Project
4=Side Project
5=Entertainment
6=File Management
7=Gaming
8=System Admin
EOF
```

#### Adding Workspace Change Hooks

The system calls `workspace-changed.sh` whenever workspace changes. You can override this script to add custom actions:

```bash
# Copy and customize the workspace change hook
cp /etc/xdg/hypr/scripts/workspace-changed.sh ~/.config/hypr/scripts/

# Edit to add your custom logic:
# - Change wallpaper per workspace
# - Start/stop applications
# - Adjust system settings
# - etc.
```

### Behind the Scenes

The workspace management system consists of:

- **`workspace-switcher.sh`** - Fuzzel-based workspace selector
- **`workspace-names.sh`** - Name management utility  
- **`workspace-changed.sh`** - Change trigger hook
- **`workspace-display.sh`** - Waybar widget script
- **`workspace-names.conf`** - Name mappings configuration

All scripts support XDG user overrides and follow the same override patterns as other configuration files.

## Productivity & Accessibility Tools

The module includes several integrated tools for productivity and accessibility, all using fuzzel interfaces with consistent Kartoza theming:

### Secure Clipboard Manager

- **Keybinding**: `Super + ,` (comma)
- **Technology**: clipse + fuzzel integration
- **Features**: 
  - Encrypted clipboard history storage
  - Beautiful fuzzel interface with numbered entries
  - Preview of clipboard content with newline indicators
  - Secure storage protects sensitive data

### Emoji Picker

- **Keybinding**: `Super + .` (period)  
- **Technology**: fuzzel + comprehensive emoji database
- **Features**:
  - Searchable emoji database with descriptions
  - Types emoji at cursor and copies to clipboard
  - Fuzzel interface with consistent theming
  - Supports all Unicode emoji categories

### Screen Recording

- **Keybinding**: `Ctrl + 6`
- **Technology**: wf-recorder with Hyprland integration
- **Features**:
  - Toggle recording on/off with single keybind
  - Multi-monitor support (records focused monitor)
  - Audio recording included
  - High-quality H.264 encoding
  - Saves to `~/Videos/Screencasts/` with timestamped names
  - Visual notifications for recording status

### Desktop Zoom (Accessibility)

- **Keybindings**: 
  - `Super + Shift + Scroll Up` - Zoom in
  - `Super + Shift + Scroll Down` - Zoom out  
  - `Super + Shift + Z` - Reset zoom to 1x
- **Technology**: Hyprland cursor zoom feature
- **Features**:
  - Real-time desktop magnification like Wayfire
  - Perfect for accessibility needs
  - Great for screencasts and presentations
  - Smooth zoom transitions
  - No performance impact when not zooming

### On-Screen Key Display

- **Keybinding**: `Super + -`
- **Technology**: wshowkeys with Kartoza theming
- **Features**:
  - Shows pressed keys on screen
  - Perfect for tutorials and presentations
  - Kartoza color scheme integration
  - Toggle on/off functionality
  - Customizable position and appearance

### Usage Examples

```bash
# Show clipboard history
Super + ,

# Insert emoji at cursor
Super + .

# Start/stop screen recording  
Ctrl + 6

# Zoom in for accessibility/presentations
Super + Shift + Scroll Up

# Show keys for tutorial recording
Ctrl + Super + K
```

### Customization

All tools respect XDG configuration overrides. You can customize:

```bash
# Customize clipboard settings
cp /etc/xdg/hypr/scripts/clipboard.sh ~/.config/hypr/scripts/
# Edit ~/.config/hypr/scripts/clipboard.sh

# Customize emoji picker
cp /etc/xdg/fuzzel/fuzzel-emoji ~/.config/fuzzel/
# Edit ~/.config/fuzzel/fuzzel-emoji

# Customize wshowkeys appearance
cp /etc/xdg/hypr/scripts/wshowkeys-toggle.sh ~/.config/hypr/scripts/
# Edit font, colors, position in ~/.config/hypr/scripts/wshowkeys-toggle.sh
```

## Customizing Dotfiles

This module deploys configuration files to `/etc/xdg/` for system-wide availability. Users can override these configurations by creating local dotfiles in their home directories.

### Override Priority

Configuration files are loaded in this order (highest to lowest priority):

1. **User home directory**: `~/.config/hypr/`, `~/.config/waybar/`, etc.
2. **System XDG config**: `/etc/xdg/hypr/`, `/etc/xdg/waybar/`, etc. (this module)
3. **Application defaults**: Built-in application defaults

### How to Override System Dotfiles

#### Method 1: Copy and Modify (Recommended)

Copy the system configurations to your home directory and modify them:

```bash
# Copy hyprland config for customization
mkdir -p ~/.config/hypr
cp /etc/xdg/hypr/hyprland.conf ~/.config/hypr/
# Edit ~/.config/hypr/hyprland.conf as needed

# Copy waybar config for customization  
mkdir -p ~/.config/waybar
cp /etc/xdg/waybar/config ~/.config/waybar/
cp /etc/xdg/waybar/style.css ~/.config/waybar/
# Edit ~/.config/waybar/ files as needed

# Copy mako config for customization
mkdir -p ~/.config/mako  
cp /etc/xdg/mako/kartoza ~/.config/mako/config
# Edit ~/.config/mako/config as needed
```

#### Method 2: Selective Overrides

You can override specific applications without copying entire configurations:

**Hyprland**: Create `~/.config/hypr/hyprland.conf` with your custom configuration. You can include the system config and add overrides, or replace it entirely.

**Waybar**: Create `~/.config/waybar/` with your own `config` and `style.css`. For modular waybar configs, you can also copy the `config.d/` directory and modify specific modules.

**Mako**: Create `~/.config/mako/config` with your notification preferences.

#### Method 3: Environment-Specific Configurations

For different environments (work, home, etc.), you can customize Hyprland configuration:

```bash
# In ~/.config/hypr/hyprland.conf

# Include the system config as base
source=/etc/xdg/hypr/hyprland.conf

# Override specific settings
general {
    layout = master  # Use master layout instead of dwindle
}

# Add custom keybinds
bind = $mainMod, T, exec, alacritty  # Use alacritty instead of kitty

# Override window rules
windowrulev2 = tile, class:.*  # Tile all windows by default instead of floating
```

#### Method 4: Waybar Modular Override

For waybar specifically, you can override individual modules:

```bash
# Copy the modular config system
mkdir -p ~/.config/waybar/config.d
cp -r /etc/xdg/waybar/config.d/* ~/.config/waybar/config.d/

# Modify specific modules
echo '{
  "custom/my-widget": {
    "format": "My Custom Widget",
    "on-click": "my-command"
  }
}' > ~/.config/waybar/config.d/99-my-custom-widget.json

# Rebuild the config (run this after making changes)
cd ~/.config/waybar
/etc/xdg/waybar/build-config.sh

# Restart waybar to apply changes
killall waybar
waybar &
```

### Important Notes

- **Backup your changes**: User configurations are not managed by Nix, so back them up separately
- **System updates**: When this module is updated, you may want to compare your local configs with the new system configs
- **Script paths**: If you copy scripts, update their paths in your local configs to point to your home directory
- **Restarting services**: After changing configs, restart the relevant applications (waybar, mako, etc.)

## Dependencies

None! This module is completely self-contained and doesn't require any external configuration.

## Structure

- `modules/hyprland-desktop.nix` - Main NixOS module
- `dotfiles/` - Configuration files for Hyprland and related applications
- `resources/` - Images and other static resources

## Development

### Local Development Setup

Enter development shell:
```bash
nix develop
```

Format code:
```bash
nix fmt
```

### Testing with QEMU VM

You can test the desktop environment in a VM without affecting your main system:

```bash
# Run the test VM (builds automatically)
./run-vm.sh

# Or run directly:
nix run .#nixosConfigurations.vm-test.config.system.build.vm
```

The VM includes:
- 4GB RAM, 4 CPU cores, 8GB disk
- Auto-login as `testuser` (password: `test`)
- Full Hyprland desktop with all components including working taskbar
- Hardware-accelerated graphics (1920x1080)
- Basic applications for testing (Firefox, file manager, terminal)
- Floating windows by default with tiling mode available (Super+F)

### Testing Changes on Existing NixOS Systems

If you're running a NixOS system that already imports this flake, you can test local changes before committing:

#### Method 1: Local Path Override (Recommended for Development)

In your main system flake, temporarily override the hyprland-desktop input to point to your local development copy:

```nix
{
  inputs = {
    hyprland-desktop.url = "path:/path/to/your/local/nix-hyprland-desktop";
    # Or use a relative path if your system flake is in a parent directory:
    # hyprland-desktop.url = "path:./nix-hyprland-desktop";
    # ... other inputs
  };
}
```

Then rebuild your system:
```bash
sudo nixos-rebuild switch --flake .#your-hostname
```

#### Method 2: Update Flake Input After Remote Changes

If you've pushed changes to the remote repository:

```bash
# In your system flake directory, update only this flake
nix flake lock --update-input hyprland-desktop

# Then rebuild
sudo nixos-rebuild switch --flake .#your-hostname
```

#### Method 3: Branch Testing

Create a branch with your changes and test it:

```bash
# In this repository
git checkout -b feature/my-changes
git add . && git commit -m "Test changes"

# In your system flake, temporarily change the input
# hyprland-desktop.url = "github:kartoza/nix-hyprland-desktop/feature/my-changes";
```

#### Method 4: Quick Waybar Configuration Testing

For rapid waybar configuration testing without full system rebuilds:

```bash
cd /path/to/nix-hyprland-desktop/dotfiles/waybar

# Build the modular config
./build-config.sh

# Test waybar with your changes (creates temporary second instance)
waybar -c config -s style.css --log-level debug
```

This method is useful for CSS styling and layout changes, but won't reflect module-level changes.

### Deploying Changes

#### For Development/Testing Systems

1. Make changes in this repository
2. Use local path override method above
3. Test with `sudo nixos-rebuild switch`

#### For Production Deployment

1. Commit and push changes to a branch
2. Test the branch using Method 3 above
3. Create a pull request and merge to main
4. Update your system flake to use the new commit:
   ```bash
   nix flake lock --update-input hyprland-desktop
   ```
5. Deploy with `sudo nixos-rebuild switch`

### Configuration Deployment to User Home

After system rebuild, configuration files are available system-wide in `/etc`. To deploy them to user home directories:

```bash
deploy-hyprland-configs
```

This is useful when users want to customize configurations locally.

## Security & Authentication

### SSH and GPG Key Management

This configuration provides seamless integration between SSH/GPG keys and the GNOME Keyring:

#### Features
- **Automatic unlock**: GPG keys become available when you unlock your keychain at login
- **SSH agent integration**: SSH keys stored in GNOME Keyring are automatically available
- **GUI password prompts**: Uses `pinentry-gnome3` for secure password entry
- **Session persistence**: Keys remain unlocked for the duration of your session

#### How It Works

1. **At Login**: PAM automatically unlocks GNOME Keyring using your login password
2. **GPG Integration**: The GPG agent connects to the keyring and uses GUI prompts for passwords
3. **SSH Integration**: SSH agent socket is exposed via `SSH_AUTH_SOCK` environment variable

#### Manual Keyring Management

If you need to manually unlock your keyring (e.g., after screen lock):

```bash
unlock-keyring
```

This script will:
- Check if GNOME Keyring is running
- Prompt for your password if the keyring is locked
- Connect the GPG agent to the newly unlocked keyring
- Display status notifications

#### Adding SSH Keys

To add SSH keys to the keyring:

```bash
ssh-add ~/.ssh/your_private_key
```

#### Adding GPG Keys

GPG keys are automatically detected when stored in `~/.gnupg/`. The configuration includes:

- **Keyserver**: Uses `hkps://keys.openpgp.org` for key retrieval
- **Caching**: Keys are cached for 8 hours (28800 seconds)
- **Auto-retrieval**: Automatically downloads missing public keys when needed

#### Configuration Files

The system automatically creates GPG configuration files in your home directory:

- `~/.gnupg/gpg-agent.conf`: GPG agent configuration with GUI pinentry
- `~/.gnupg/gpg.conf`: Basic GPG settings with keyserver configuration

These files are created automatically by the `deploy-hyprland-configs` script if they don't already exist.

#### Troubleshooting

**GPG keys not accessible:**
```bash
# Check GPG agent status
gpg-connect-agent 'keyinfo --list' /bye

# Restart GPG agent if needed
gpg-connect-agent killagent /bye
gpg-connect-agent /bye
```

**SSH keys not loading:**
```bash
# Check SSH agent
echo $SSH_AUTH_SOCK
ssh-add -l

# If keyring SSH agent isn't working, check:
pgrep gnome-keyring-daemon
```

**Keyring not unlocking:**
- Ensure your user password matches your keyring password
- The keyring password is typically set to your login password during first login
- Use `seahorse` (GNOME Passwords and Keys) to manage keyring passwords if needed
