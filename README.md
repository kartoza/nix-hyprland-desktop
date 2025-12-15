# Kartoza Wayfire Desktop Configuration

A standalone NixOS flake for configuring Wayfire desktop environment with Kartoza theming and customizations.

## Overview

This flake provides a complete Wayfire desktop environment configuration that can be imported into any NixOS flake. It includes:

- Wayfire compositor with plugins
- Waybar status bar with modular configuration
- Nwggrid and nwgpanel application launcher
- Mako notification daemon
- Fuzzel and other utilities
- Complete theming and styling
- GNOME Keyring integration with SSH and GPG support

## Usage

### Step 1: Add Flake Input

Add this flake as an input to your NixOS configuration:

```nix
{
  inputs = {
    wayfire-desktop.url = "github:kartoza/nix-wayfire-desktop";
    # ... other inputs
  };
}
```

### Step 2: Import and Enable Module

Import the module and enable it in your NixOS configuration:

```nix
{
  imports = [
    wayfire-desktop.nixosModules.default
    # ... other modules
  ];

  # Enable Kartoza Wayfire Desktop with one line!
  kartoza.wayfire-desktop.enable = true;
}
```

### Step 3: Configure Display Manager (CRITICAL)

**IMPORTANT**: You must configure your display manager to start Wayfire with the correct configuration file. The module configures greetd as the display manager, but you need to set the initial session command in your user configuration:

```nix
{
  # Configure greetd to auto-login with Wayfire
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd 'wayfire -c /etc/xdg/wayfire/wayfire.ini'";
        user = "greeter";
      };
      
      # Optional: Auto-login for a specific user
      initial_session = {
        command = "wayfire -c /etc/xdg/wayfire/wayfire.ini";
        user = "your-username";  # Replace with your actual username
      };
    };
  };
}
```

**Critical Parameter**:
- `-c /etc/xdg/wayfire/wayfire.ini` - Ensures Wayfire uses the module's configuration

Without this parameter, Wayfire will use default configs and the desktop environment may not work correctly.

### Step 4: Rebuild System

After configuration, rebuild your system:

```bash
sudo nixos-rebuild switch --flake .#your-hostname
```

### Configuration Options

```nix
{
  kartoza.wayfire-desktop = {
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
  };
}
```

## Customizing Dotfiles

This module deploys configuration files to `/etc/xdg/` for system-wide availability. Users can override these configurations by creating local dotfiles in their home directories.

### Override Priority

Configuration files are loaded in this order (highest to lowest priority):

1. **User home directory**: `~/.config/wayfire/`, `~/.config/waybar/`, etc.
2. **System XDG config**: `/etc/xdg/wayfire/`, `/etc/xdg/waybar/`, etc. (this module)
3. **Application defaults**: Built-in application defaults

### How to Override System Dotfiles

#### Method 1: Copy and Modify (Recommended)

Copy the system configurations to your home directory and modify them:

```bash
# Copy wayfire config for customization
mkdir -p ~/.config/wayfire
cp /etc/xdg/wayfire/wayfire.ini ~/.config/wayfire/
# Edit ~/.config/wayfire/wayfire.ini as needed

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

**Wayfire**: Create `~/.config/wayfire/wayfire.ini` with only the settings you want to change. Wayfire will merge your changes with the system configuration.

**Waybar**: Create `~/.config/waybar/` with your own `config` and `style.css`. For modular waybar configs, you can also copy the `config.d/` directory and modify specific modules.

**Mako**: Create `~/.config/mako/config` with your notification preferences.

#### Method 3: Environment-Specific Configurations

For different environments (work, home, etc.), you can use environment variables or conditional logic:

```ini
# In ~/.config/wayfire/wayfire.ini
[core]
plugins = animate command cube decoration expo fast-switcher
# Add/remove plugins based on your needs

[command]  
# Override specific keybindings
binding_terminal = <super> KEY_RETURN
command_terminal = alacritty  # Use different terminal
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

- `modules/wayfire-desktop.nix` - Main NixOS module
- `dotfiles/` - Configuration files for Wayfire and related applications
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
- Full Wayfire desktop with all components
- Hardware-accelerated graphics (1920x1080)
- Basic applications for testing (Firefox, file manager, terminal)

### Testing Changes on Existing NixOS Systems

If you're running a NixOS system that already imports this flake, you can test local changes before committing:

#### Method 1: Local Path Override (Recommended for Development)

In your main system flake, temporarily override the wayfire-desktop input to point to your local development copy:

```nix
{
  inputs = {
    wayfire-desktop.url = "path:/path/to/your/local/nix-wayfire-desktop";
    # Or use a relative path if your system flake is in a parent directory:
    # wayfire-desktop.url = "path:./nix-wayfire-desktop";
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
nix flake lock --update-input wayfire-desktop

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
# wayfire-desktop.url = "github:kartoza/nix-wayfire-desktop/feature/my-changes";
```

#### Method 4: Quick Waybar Configuration Testing

For rapid waybar configuration testing without full system rebuilds:

```bash
cd /path/to/nix-wayfire-desktop/dotfiles/waybar

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
   nix flake lock --update-input wayfire-desktop
   ```
5. Deploy with `sudo nixos-rebuild switch`

### Configuration Deployment to User Home

After system rebuild, configuration files are available system-wide in `/etc`. To deploy them to user home directories:

```bash
deploy-wayfire-configs
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

These files are created automatically by the `deploy-wayfire-configs` script if they don't already exist.

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
