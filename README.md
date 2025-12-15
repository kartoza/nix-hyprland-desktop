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
- GNOME Keyring integration with SSH and GPG support

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

### Local Development Setup

Enter development shell:
```bash
nix develop
```

Format code:
```bash
nix fmt
```

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