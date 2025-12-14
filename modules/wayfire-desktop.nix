{
  config,
  lib,
  pkgs,
  ...
}:

let
  wayfireEnabled = config.programs.wayfire.enable or false;
  
  # Allow configuration of icon theme, with Papirus as default
  iconThemeName = config.kartoza.theme.iconTheme.name or "Papirus";
in
{

  # Deploy essential Wayfire dotfiles at system level
  # Enable the X server.
  services.xserver.enable = true;

  programs.wayfire = {
    enable = true;
    plugins = with pkgs.wayfirePlugins; [
      wcm
      wf-shell
      wayfire-plugins-extra
    ];
  };

  # Enable NetworkManager service for network and VPN management
  networking.networkmanager.enable = true;

  # Enable polkit for permission management (required for nm-applet)
  security.polkit.enable = true;

  environment.systemPackages = with pkgs; [
    # Default icon theme (Papirus) - can be overridden by kartoza.nix or other configs
    papirus-icon-theme
    # Cursor theme is managed by home-manager (see home/default.nix)
    # Add these for better app compatibility
    audio-recorder
    blueman # Bluetooth manager with system tray
    bluez-tools # Command line tools for Bluetooth
    brightnessctl # Brightness control for waybar
    clipse # Wayland clipboard manager
    dmenu
    evince
    fuzzel # Application launcher for Wayland
    gnome-disk-utility # GNOME Disks application
    gnome-secrets
    grim # Screenshot utility for Wayland
    gvfs # Virtual file system implementation for GIO
    junction # URL handler/browser chooser
    libnotify # Provides notify-send command for desktop notifications
    libreoffice
    libsecret # For secret-tool command
    libsForQt5.qt5.qtwayland
    lm_sensors # Temperature monitoring
    mako # Notification daemon for Wayland
    nautilus # File manager
    networkmanager
    networkmanagerapplet # System tray applet for NetworkManager
    nwg-launchers # Application launchers for Wayland
    nwg-look # GTK theme configuration tool
    nwg-wrapper # Wrapper script to launch apps with proper env for Wayland
    pipewire # Multimedia framework for audio and video
    power-profiles-daemon # Power profile management
    qt5.qtwayland # Qt5 Wayland platform plugin
    qt6.qtwayland # Qt6 Wayland platform plugin
    seahorse # GUI for managing gnome-keyring
    slurp # Region selector for screenshots
    sushi # File previewer for Nautilus (spacebar preview)
    sway-contrib.grimshot # Screenshot tool for Wayland
    swayidle # Idle management for Wayland
    swaylock-effects # Screen locker with effects for Wayland
    swayr # Visual window switcher with overlay
    swww # Wallpaper setter (works with Wayfire too)
    util-linux # Provides rfkill tool to enable/disable wireless devices
    waybar # Bar panel for Wayland
    wayfire # Wayfire compositor with lots of nice eye candy
    wayfirePlugins.wayfire-plugins-extra
    wayfirePlugins.wcm # Wayfire Config Manager
    wayfirePlugins.wf-shell
    wf-recorder # Wayland screen recorder
    wireplumber
    wl-clipboard
    wlr-randr # Display configuration for wlr compositors
    wlrctl # Wayfire window management and inspection tool
    wtype # Wayland typing utility
    wev # Wayland event viewer for debugging
    xdg-desktop-portal-gtk
    xdg-desktop-portal-wlr # For screen sharing in Wayfire
    zenity # GUI dialogs for keyring unlock
    # Deploy script for system-wide Wayfire config management
    jq # Required for waybar config building
    # Keyring unlock script for login
    (writeScriptBin "unlock-keyring" ''
      #!/usr/bin/env bash

      # Script to unlock GNOME Keyring at Wayfire login
      # This ensures the keyring is available for SSH keys and other secrets

      # Check if gnome-keyring-daemon is already running
      if pgrep -x gnome-keyring-daemon >/dev/null; then
          echo "GNOME Keyring daemon is already running"

          # Check if the default keyring is unlocked
          if ! ${pkgs.libsecret}/bin/secret-tool lookup service test 2>/dev/null; then
              echo "Keyring appears to be locked, attempting to unlock..."

              # Use zenity to prompt for password to unlock keyring
              password=$(${pkgs.zenity}/bin/zenity --password --title="Unlock Keyring" --text="Please enter your password to unlock the keyring:")

              if [ -n "$password" ]; then
                  # Attempt to unlock keyring
                  echo -n "$password" | ${pkgs.gnome-keyring}/bin/gnome-keyring-daemon --unlock --daemonize

                  if [ $? -eq 0 ]; then
                      ${pkgs.libnotify}/bin/notify-send "Keyring Unlocked" "Your keyring has been successfully unlocked"
                  else
                      ${pkgs.libnotify}/bin/notify-send "Keyring Unlock Failed" "Failed to unlock keyring with provided password"
                  fi
              else
                  ${pkgs.libnotify}/bin/notify-send "Keyring Unlock Cancelled" "Keyring unlock was cancelled"
              fi
          else
              echo "Keyring is already unlocked"
              ${pkgs.libnotify}/bin/notify-send "Keyring Ready" "Your keyring is already unlocked and ready"
          fi
      else
          echo "GNOME Keyring daemon not running, this should have been started by PAM"
          ${pkgs.libnotify}/bin/notify-send "Keyring Error" "GNOME Keyring daemon is not running"
      fi
    '')
    (writeScriptBin "deploy-wayfire-configs" ''
      #!/bin/bash
      # Deploy Wayfire configs to user's home directory
      USER_HOME="$HOME"
      if [ -z "$USER_HOME" ]; then
        USER_HOME="/home/$USER"
      fi

      echo "Deploying Wayfire configuration files to $USER_HOME..."

      # Create config directories
      mkdir -p "$USER_HOME/.config/wayfire"
      mkdir -p "$USER_HOME/.config/waybar"
      mkdir -p "$USER_HOME/.config/wofi"
      mkdir -p "$USER_HOME/.config/wofi-emoji"
      mkdir -p "$USER_HOME/.config/mako"
      mkdir -p "$USER_HOME/.config/nwg-launchers/nwggrid"
      mkdir -p "$USER_HOME/.config/nwg-launchers/nwgbar"
      mkdir -p "$USER_HOME/.config/waybar/scripts"
      mkdir -p "$USER_HOME/.config/wayfire/scripts"
      mkdir -p "$USER_HOME/.local/bin"

      # Copy configuration files from /etc
      cp /etc/wayfire/wayfire.ini "$USER_HOME/.config/wayfire/wayfire.ini"
      cp /etc/xdg/waybar/style.css "$USER_HOME/.config/waybar/style.css"
      cp /etc/xdg/waybar/config "$USER_HOME/.config/waybar/config"

      cp /etc/wofi/config "$USER_HOME/.config/wofi/config"
      cp /etc/wofi/style.css "$USER_HOME/.config/wofi/style.css"
      cp /etc/wofi-emoji/config "$USER_HOME/.config/wofi-emoji/config"
      cp /etc/mako/kartoza "$USER_HOME/.config/mako/kartoza"
      cp /etc/nwg-launchers/nwggrid/style.css "$USER_HOME/.config/nwg-launchers/nwggrid/style.css"
      cp /etc/nwg-launchers/nwgbar/style.css "$USER_HOME/.config/nwg-launchers/nwgbar/style.css"

      # Copy scripts and resources
      cp -r /etc/xdg/waybar/scripts/* "$USER_HOME/.config/waybar/scripts/"
      cp -r /etc/wayfire/scripts/* "$USER_HOME/.config/wayfire/scripts/"
      cp /etc/xdg/waybar/kartoza-logo-neon.png "$USER_HOME/.config/waybar/"
      cp /etc/xdg/waybar/kartoza-logo-neon-bright.png "$USER_HOME/.config/waybar/"
      cp /etc/fuzzel/fuzzel-emoji "$USER_HOME/.local/bin/fuzzel-emoji"

      # Set permissions
      chmod 644 "$USER_HOME/.config/wayfire/wayfire.ini"
      chmod 644 "$USER_HOME/.config/waybar/style.css"
      chmod 644 "$USER_HOME/.config/waybar/config"
      chmod 644 "$USER_HOME/.config/wofi/config"
      chmod 644 "$USER_HOME/.config/wofi/style.css"
      chmod 644 "$USER_HOME/.config/wofi-emoji/config"
      chmod 644 "$USER_HOME/.config/mako/kartoza"
      chmod 644 "$USER_HOME/.config/nwg-launchers/nwggrid/style.css"
      chmod 644 "$USER_HOME/.config/nwg-launchers/nwgbar/style.css"
      chmod 644 "$USER_HOME/.config/waybar/kartoza-logo-neon.png"
      chmod 644 "$USER_HOME/.config/waybar/kartoza-logo-neon-bright.png"
      # Make scripts executable
      chmod +x "$USER_HOME/.config/waybar/scripts"/*
      chmod +x "$USER_HOME/.config/wayfire/scripts"/*
      chmod +x "$USER_HOME/.local/bin/fuzzel-emoji"

      echo "Wayfire configuration deployment complete!"
    '')
  ];

  environment.sessionVariables = {
    XDG_SESSION_TYPE = "wayland";
    # Wayfire sets this to "wayfire"
    XDG_CURRENT_DESKTOP = "wayfire";
    XDG_SESSION_DESKTOP = "wayfire";
    # Cursor theme and size are managed by home-manager (see home/default.nix)
    # Enable gnome-keyring SSH agent
    SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/keyring/ssh";
    # Browser configuration
    DEFAULT_BROWSER = "${pkgs.junction}/bin/re.sonny.Junction";
    BROWSER = "re.sonny.Junction";
    # Add script directories to PATH
    PATH = [
      "/etc/fuzzel"
      "/etc/wayfire/scripts"
      "/etc/xdg/waybar/scripts"
    ];
  };

  environment.variables = {
    # Environment variables for better Wayland app compatibility
    QT_QPA_PLATFORM = "wayland";
    MOZ_ENABLE_WAYLAND = "1";
    GDK_BACKEND = "wayland,x11"; # Fallback to X11 if needed
    ELECTRON_OZONE_PLATFORM_HINT = "wayland"; # Better for Electron apps
    # Force apps to use Wayland when available
    SDL_VIDEODRIVER = "wayland";
    CLUTTER_BACKEND = "wayland";
    # XWayland fallback
    QT_QPA_PLATFORMTHEME = "gnome";
  };

  # GTK theme configuration for GNOME/GTK apps
  programs.dconf.enable = true;

  # Set GTK settings system-wide
  # Note: cursor theme is managed by home-manager
  # Icon theme is centrally managed via kartoza.nix
  environment.etc."gtk-3.0/settings.ini".text = ''
    [Settings]
    gtk-icon-theme-name=${iconThemeName}
    gtk-theme-name=Adwaita
    gtk-application-prefer-dark-theme=false
  '';

  environment.etc."gtk-4.0/settings.ini".text = ''
    [Settings]
    gtk-icon-theme-name=${iconThemeName}
  '';

  # Deploy Wayfire configuration files system-wide
  environment.etc = {
    # Wayfire main config
    "wayfire/wayfire.ini".source = ../dotfiles/wayfire/wayfire.ini;
    # Waybar configuration
    "xdg/waybar/style.css".source = ../dotfiles/waybar/style.css;
    # Build combined waybar config from modular JSON files
    "xdg/waybar/config" = {
      source =
        pkgs.runCommand "waybar-config-wayfire"
          {
            nativeBuildInputs = [ pkgs.jq ];
          }
          ''
            src=${../dotfiles/waybar/config.d}

            # Use Wayfire base config instead of regular base
            cat "$src/00-base-wayfire.json" > config.json

            # Merge all other config fragments except sway-specific ones and generic power
            for file in "$src"/*.json; do
              filename=$(basename "$file")
              # Skip base files, sway-specific modules, and generic power (use wayfire-specific)
              if [[ "$filename" != "00-base.json" && "$filename" != "00-base-wayfire.json" &&
                    "$filename" != "90-sway-"* && "$filename" != "90-custom-power.json" ]]; then
                echo "Merging $filename"
                jq -s '.[0] * .[1]' config.json "$file" > temp.json
                mv temp.json config.json
              fi
            done

            cp config.json $out
          '';
    };
    # Wofi configuration
    "wofi/config".source = ../dotfiles/wofi/config;
    "wofi/style.css".source = ../dotfiles/wofi/style.css;
    "wofi-emoji/config".source = ../dotfiles/wofi-emoji/config;
    # Mako notification config
    "mako/kartoza".source = ../dotfiles/mako/kartoza;
    # nwg-launchers configs
    "nwg-launchers/nwggrid/style.css".source = ../dotfiles/nwggrid/style.css;
    "nwg-launchers/nwgbar/style.css".source = ../dotfiles/nwgbar/style.css;
    # Waybar scripts and resources
    "xdg/waybar/scripts".source = ../dotfiles/waybar/scripts;
    "wayfire/scripts".source = ../dotfiles/wayfire/scripts;
    "xdg/waybar/kartoza-logo-neon.png".source = ../resources/kartoza-logo-neon.png;
    "xdg/waybar/kartoza-logo-neon-bright.png".source = ../resources/kartoza-logo-neon-bright.png;
    # Fuzzel emoji script
    "fuzzel/fuzzel-emoji".source = ../dotfiles/fuzzel/fuzzel-emoji;
  };

  # Required for screen sharing
  services.pipewire = {
    enable = true;
    audio.enable = true;
    alsa.enable = true;
    pulse.enable = true;
    jack.enable = true;
  };

  services.dbus = {
    enable = true;
  };

  # Enable automounting for removable media (USB drives, etc.)
  services.udisks2.enable = true;
  services.gvfs.enable = true;

  # Enable power profile management
  services.power-profiles-daemon.enable = true;

  # Enable gnome-keyring service for SSH and GPG key caching
  services.gnome.gnome-keyring.enable = true;

  # Configure PAM for greetd to unlock gnome-keyring on login
  security.pam.services.greetd = {
    enableGnomeKeyring = true;
    gnupg.enable = true;
  };

  # Configure PAM for swaylock to unlock gnome-keyring when unlocking screen
  # Also enable fingerprint authentication (fprintd) for unlocking
  security.pam.services.swaylock = {
    enableGnomeKeyring = true;
    fprintAuth = true;
    gnupg.enable = true;
  };

  # Configure PAM for login sessions
  security.pam.services.login = {
    enableGnomeKeyring = true;
    gnupg.enable = true;
  };

  # Configure PAM for sudo to maintain keyring access
  security.pam.services.sudo = {
    enableGnomeKeyring = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-wlr # For Wayfire screen sharing
    ];
    # Configure portal backends for Wayfire
    config = {
      wayfire = {
        default = lib.mkForce [
          "gtk"
          "wlr"
        ];
        "org.freedesktop.impl.portal.FileChooser" = lib.mkForce [ "gtk" ];
        "org.freedesktop.impl.portal.AppChooser" = lib.mkForce [ "gtk" ];
        "org.freedesktop.impl.portal.ScreenCast" = lib.mkForce [ "wlr" ];
        "org.freedesktop.impl.portal.Screenshot" = lib.mkForce [ "wlr" ];
      };
    };
    # Ensures the right backend is selected
    xdgOpenUsePortal = true;
    wlr.enable = true;
  };

  # Configure default applications for MIME types
  environment.etc."xdg/mimeapps.list".text = ''
    [Default Applications]
    application/pdf=org.gnome.Evince.desktop
    text/plain=org.gnome.TextEditor.desktop
    image/jpeg=org.gnome.eog.desktop
    image/png=org.gnome.eog.desktop

    [Added Associations]
    application/pdf=org.gnome.Evince.desktop
  '';

  # Import environment variables into systemd user session
  systemd.user.extraConfig = ''
    DefaultEnvironment="WAYLAND_DISPLAY=wayland-1"
    DefaultEnvironment="XDG_CURRENT_DESKTOP=wayfire"
    DefaultEnvironment="XDG_SESSION_DESKTOP=wayfire"
    DefaultEnvironment="XDG_SESSION_TYPE=wayland"
  '';

  # For Wayfire (no display manager), we use greetd
  # Note: Autologin is configured per-host in hosts/<hostname>/desktop.nix
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd wayfire";
        user = "greeter";
      };
    };
  };
}
