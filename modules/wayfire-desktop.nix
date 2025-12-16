{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.kartoza.wayfire-desktop;

  # Use the icon theme from the module configuration
  iconThemeName = cfg.iconTheme;

  # Helper function to find config files in XDG paths (user config takes precedence)
  findConfigFile = configPath: ''
    if [[ -f "$HOME/.config/${configPath}" ]]; then
      echo "$HOME/.config/${configPath}"
    else
      echo "/etc/xdg/${configPath}"
    fi
  '';

  # Helper script to resolve XDG config paths at runtime
  xdgConfigResolver = pkgs.writeScriptBin "xdg-config-resolve" ''
    #!/usr/bin/env bash
    # Resolves XDG config paths, checking user config first, then system
    config_path="$1"
    if [[ -f "$HOME/.config/$config_path" ]]; then
      echo "$HOME/.config/$config_path"
    elif [[ -f "/etc/xdg/$config_path" ]]; then
      echo "/etc/xdg/$config_path"
    else
      echo "Config file not found: $config_path" >&2
      exit 1
    fi
  '';
in {
  options = {
    kartoza.wayfire-desktop = {
      enable = mkEnableOption "Kartoza Wayfire Desktop Environment";

      iconTheme = mkOption {
        type = types.str;
        default = "Papirus";
        description = "Icon theme to use for the desktop";
      };

      gtkTheme = mkOption {
        type = types.str;
        default = "Adwaita";
        description = "GTK theme to use for GTK applications";
      };

      fractionalScaling = mkOption {
        type = types.float;
        default = 1.0;
        description =
          "Fractional scaling factor for displays (1.0 = 100%, 1.25 = 125%, 1.5 = 150%, etc.)";
      };

      qtTheme = mkOption {
        type = types.str;
        default = "gnome";
        description =
          "Qt platform theme to use for Qt applications (gnome, gtk2, kde, fusion)";
      };

      darkTheme = mkOption {
        type = types.bool;
        default = true;
        description =
          "Whether to use dark theme for GTK applications (defaults to true)";
      };

      displayScaling = mkOption {
        type = types.attrsOf types.float;
        default = { };
        example = {
          "eDP-1" = 1.5;
          "DP-9" = 1.0;
        };
        description =
          "Per-display scaling factors. Use display names as keys (e.g., eDP-1, DP-9) and scaling factors as values.";
      };

      cursorTheme = mkOption {
        type = types.str;
        default = "Vanilla-DMZ";
        description = "Cursor theme to use (Vanilla-DMZ, Adwaita, etc.)";
      };

      cursorSize = mkOption {
        type = types.int;
        default = 24;
        description = "Cursor size in pixels";
      };

      keyboardLayouts = mkOption {
        type = types.listOf types.str;
        default = [ "us" "pt" ];
        example = [ "us" "de" "fr" ];
        description = "List of keyboard layouts (first layout is default, others accessible via Alt+Shift toggle)";
      };

      wallpaper = mkOption {
        type = types.str;
        default = "/etc/kartoza-wallpaper.png";
        example = "/home/user/Pictures/my-wallpaper.jpg";
        description = "Path to wallpaper image used for both desktop background and swaylock screen";
      };
    };
  };

  config = mkIf cfg.enable {

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
      # XDG config path resolver utility
      xdgConfigResolver
      # Default icon theme (Papirus) - can be overridden by kartoza.nix or other configs
      papirus-icon-theme
      # Essential fonts for waybar and wayfire
      font-awesome # For waybar icons (required for waybar symbols)
      noto-fonts # Good fallback font family
      noto-fonts-cjk-sans # CJK character support
      noto-fonts-emoji # Emoji support
      liberation_ttf # Good sans-serif fonts
      dejavu_fonts # DejaVu fonts (good fallback)
      source-sans # Adobe Source Sans Pro (modern, clean)
      ubuntu_font_family # Ubuntu fonts (similar to nunito)
      # Cursor themes
      vanilla-dmz # Default cursor theme
      adwaita-icon-theme # Includes Adwaita cursor theme
      # GPG integration packages
      gnupg
      pinentry-gnome3
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
      # Wallpaper and screen management
      swww # Efficient animated wallpaper daemon for wayland
      swayidle # Idle management daemon for Wayland
      swaylock # Screen locker for Wayland
      # Cursor theme
      vanilla-dmz # Default cursor theme
      # Image processing for wallpapers
      imagemagick # For creating default wallpaper
      # Deploy script for system-wide Wayfire config management
      jq # Required for waybar config building
      # XDG config path helper for use in config files
      (writeScriptBin "xdg-config-path" ''
        #!/usr/bin/env bash
        # Returns the path to a config file, checking user config first
        config_path="$1"
        if [[ -f "$HOME/.config/$config_path" ]]; then
          echo "$HOME/.config/$config_path"
        else
          echo "/etc/xdg/$config_path"
        fi
      '')
      # Wallpaper setup script
      (writeScriptBin "setup-wallpaper" ''
        #!/usr/bin/env bash

        # Create wallpapers directory
        mkdir -p "$HOME/wallpapers"

        # Define wallpaper paths
        SYSTEM_WALLPAPER="/etc/kartoza-wallpaper.png"
        USER_WALLPAPER="$HOME/wallpapers/timos-wallpaper.png"

        # If no user wallpaper exists, copy the Kartoza default
        if [[ ! -f "$USER_WALLPAPER" ]]; then
          if [[ -f "$SYSTEM_WALLPAPER" ]]; then
            cp "$SYSTEM_WALLPAPER" "$USER_WALLPAPER"
            echo "Copied Kartoza default wallpaper"
          else
            # Fallback: create a simple gradient
            ${pkgs.imagemagick}/bin/convert -size 1920x1080 \
              gradient:'#2d3748-#4a5568' \
              "$USER_WALLPAPER"
            echo "Created fallback gradient wallpaper"
          fi
        fi

        # Initialize swww and set wallpaper
        swww init || true
        swww img "$USER_WALLPAPER"
      '')
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
                        
                        # Start GPG agent and connect to keyring
                        export GPG_TTY=$(tty)
                        ${pkgs.gnupg}/bin/gpg-connect-agent updatestartuptty /bye >/dev/null 2>&1
                        
                        # Test GPG functionality
                        if ${pkgs.gnupg}/bin/gpg --list-secret-keys >/dev/null 2>&1; then
                            echo "GPG keys are now accessible"
                        fi
                    else
                        ${pkgs.libnotify}/bin/notify-send "Keyring Unlock Failed" "Failed to unlock keyring with provided password"
                    fi
                else
                    ${pkgs.libnotify}/bin/notify-send "Keyring Unlock Cancelled" "Keyring unlock was cancelled"
                fi
            else
                echo "Keyring is already unlocked"
                
                # Ensure GPG agent is connected
                export GPG_TTY=$(tty)
                ${pkgs.gnupg}/bin/gpg-connect-agent updatestartuptty /bye >/dev/null 2>&1
                
                ${pkgs.libnotify}/bin/notify-send "Keyring Ready" "Your keyring is already unlocked and ready"
            fi
        else
            echo "GNOME Keyring daemon not running, this should have been started by PAM"
            ${pkgs.libnotify}/bin/notify-send "Keyring Error" "GNOME Keyring daemon is not running"
        fi
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
      # Configure GPG agent socket
      GPG_TTY = "$(tty)";
      GNUPGHOME = "$HOME/.gnupg";
      # Browser configuration
      DEFAULT_BROWSER = "${pkgs.junction}/bin/re.sonny.Junction";
      BROWSER = "re.sonny.Junction";
      # Add script directories to PATH (user directories first)
      PATH = [
        "$HOME/.config/fuzzel"
        "$HOME/.config/wayfire/scripts"
        "$HOME/.config/waybar/scripts"
        "/etc/xdg/fuzzel"
        "/etc/xdg/wayfire/scripts"
        "/etc/xdg/waybar/scripts"
      ];
    };

    environment.variables = {
      # XDG environment for finding configs - user configs in ~/.config take precedence
      XDG_CONFIG_DIRS = "/etc/xdg";
      XDG_DATA_DIRS = mkDefault "/etc/xdg:/usr/local/share:/usr/share";
      # Cursor theme
      XCURSOR_THEME = cfg.cursorTheme;
      XCURSOR_SIZE = toString cfg.cursorSize;

      # Environment variables for better Wayland app compatibility
      QT_QPA_PLATFORM = "wayland";
      MOZ_ENABLE_WAYLAND = "1";
      GDK_BACKEND = "wayland,x11"; # Fallback to X11 if needed
      ELECTRON_OZONE_PLATFORM_HINT = "wayland"; # Better for Electron apps
      # Force apps to use Wayland when available
      SDL_VIDEODRIVER = "wayland";
      CLUTTER_BACKEND = "wayland";
      # XWayland fallback
      QT_QPA_PLATFORMTHEME = cfg.qtTheme;
    };

    # GTK theme configuration for GNOME/GTK apps
    programs.dconf.enable = true;

    # Set GTK settings system-wide
    # Note: cursor theme is managed by home-manager
    # Icon theme is centrally managed via kartoza.nix
    environment.etc."gtk-3.0/settings.ini".text = ''
      [Settings]
      gtk-icon-theme-name=${iconThemeName}
      gtk-theme-name=${cfg.gtkTheme}
      gtk-application-prefer-dark-theme=${lib.boolToString cfg.darkTheme}
    '';

    environment.etc."gtk-4.0/settings.ini".text = ''
      [Settings]
      gtk-icon-theme-name=${iconThemeName}
      gtk-theme-name=${cfg.gtkTheme}
      gtk-application-prefer-dark-theme=${lib.boolToString cfg.darkTheme}
    '';

    # Deploy Wayfire configuration files system-wide using standard paths
    environment.etc = {
      # Wayfire main config - generated from template with proper substitution
      "xdg/wayfire/wayfire.ini" = {
        text = let
          baseConfig = lib.readFile ../dotfiles/wayfire/wayfire.ini;
          # Generate per-display output sections
          displayOutputs = lib.concatStringsSep "\n\n" (lib.mapAttrsToList
            (display: scaling: ''
              [output:${display}]
              depth = 8
              mode = auto
              position = auto
              scale = ${toString scaling}
              transform = normal
              vrr = false
            '') cfg.displayScaling);

          # Replace template placeholders
          configWithSubstitutions = lib.replaceStrings [
            "swww init && swww img /etc/kartoza-wallpaper.png"
            "cursor_theme = default"
            "cursor_size = 24"
            "scale = 1.500000"
            "scale = 1.000000"
            "xkb_layout = us,pt"
            "mako -c /etc/xdg/mako/kartoza"
            "swaylock -f -C /etc/xdg/swaylock/config"
            "swaylock -f -c /etc/xdg/swaylock/config"
            "/etc/xdg/fuzzel/fuzzel-emoji"
            "/etc/xdg/wayfire/scripts/record-toggle.sh"
          ] [
            "swww init && swww img ${cfg.wallpaper}"
            "cursor_theme = ${cfg.cursorTheme}"
            "cursor_size = ${toString cfg.cursorSize}"
            "scale = ${toString cfg.fractionalScaling}"
            "scale = ${toString cfg.fractionalScaling}"
            "xkb_layout = ${lib.concatStringsSep "," cfg.keyboardLayouts}"
            "mako -c $(xdg-config-path mako/kartoza)"
            "swaylock -f -C $(xdg-config-path swaylock/config)"
            "swaylock -f -c $(xdg-config-path swaylock/config)"
            "$(xdg-config-path fuzzel/fuzzel-emoji)"
            "$(xdg-config-path wayfire/scripts/record-toggle.sh)"
          ] baseConfig;
        in configWithSubstitutions + "\n\n" + displayOutputs;
      };
      "xdg/wayfire/scripts".source = ../dotfiles/wayfire/scripts;
      # Waybar configuration - standard XDG location
      "xdg/waybar/style.css".source = ../dotfiles/waybar/style.css;
      # Build combined waybar config from modular JSON files
      "xdg/waybar/config" = {
        source = pkgs.runCommand "waybar-config-wayfire" {
          nativeBuildInputs = [ pkgs.jq ];
        } ''
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

          # Fix script paths to use /etc/xdg instead of /etc/waybar
          sed 's|/etc/waybar/scripts/|/etc/xdg/waybar/scripts/|g' config.json > final_config.json

          cp final_config.json $out
        '';
      };
      # Note: Using fuzzel as launcher instead of wofi
      # Mako notification config - standard XDG location
      "xdg/mako/kartoza".source = ../dotfiles/mako/kartoza;
      # Notification sound file
      "xdg/mako/sounds/notification.wav".source = ../resources/sounds/notification.wav;
      # nwg-launchers configs - standard XDG location
      "xdg/nwg-launchers/nwggrid/style.css".source =
        ../dotfiles/nwggrid/style.css;
      "xdg/nwg-launchers/nwgbar/style.css".source =
        ../dotfiles/nwgbar/style.css;
      # Waybar scripts and resources
      "xdg/waybar/scripts".source = ../dotfiles/waybar/scripts;
      "xdg/waybar/kartoza-logo-neon.png".source =
        ../resources/kartoza-logo-neon.png;
      "xdg/waybar/kartoza-logo-neon-bright.png".source =
        ../resources/kartoza-logo-neon-bright.png;
      # Kartoza default wallpaper
      "kartoza-wallpaper.png".source = ../resources/KartozaBackground.png;
      # Swaylock configuration - standard XDG location
      "xdg/swaylock/config" = {
        text = let
          baseConfig = lib.readFile ../dotfiles/swaylock/config;
          # Replace wallpaper path with configured wallpaper
          configWithWallpaper = lib.replaceStrings [
            "image=/etc/kartoza-wallpaper.png"
          ] [
            "image=${cfg.wallpaper}"
          ] baseConfig;
        in configWithWallpaper;
      };
      # Fuzzel emoji script - standard location for executables
      "xdg/fuzzel/fuzzel-emoji".source = ../dotfiles/fuzzel/fuzzel-emoji;
      # GPG agent configuration
      "skel/.gnupg/gpg-agent.conf".text = ''
        pinentry-program ${pkgs.pinentry-gnome3}/bin/pinentry-gnome3
        default-cache-ttl 28800
        max-cache-ttl 86400
        enable-ssh-support
      '';
      "skel/.gnupg/gpg.conf".text = ''
        use-agent
        keyserver hkps://keys.openpgp.org
        keyserver-options auto-key-retrieve
      '';
    };

    # Required for screen sharing
    services.pipewire = {
      enable = true;
      audio.enable = true;
      alsa.enable = true;
      pulse.enable = true;
      jack.enable = true;
    };

    services.dbus = { enable = true; };

    # Enable automounting for removable media (USB drives, etc.)
    services.udisks2.enable = true;
    services.gvfs.enable = true;

    # Enable power profile management
    services.power-profiles-daemon.enable = true;

    # Enable gnome-keyring service for SSH and GPG key caching
    services.gnome.gnome-keyring.enable = true;

    # Enable GPG agent to integrate with gnome-keyring
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryPackage = pkgs.pinentry-gnome3;
    };

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
    security.pam.services.sudo = { enableGnomeKeyring = true; };

    xdg.portal = {
      enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
        pkgs.xdg-desktop-portal-wlr # For Wayfire screen sharing
      ];
      # Configure portal backends for Wayfire
      config = {
        wayfire = {
          default = lib.mkForce [ "gtk" "wlr" ];
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
      DefaultEnvironment="SSH_AUTH_SOCK=%t/keyring/ssh"
      DefaultEnvironment="GPG_TTY=$(tty)"
    '';

    # Systemd user service to ensure GPG agent connects to keyring
    systemd.user.services.gpg-agent-connect = {
      description = "Connect GPG agent to keyring";
      after = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      wantedBy = [ "default.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.gnupg}/bin/gpg-connect-agent updatestartuptty /bye";
        Environment = "GPG_TTY=$(tty)";
      };
    };

    # For Wayfire (no display manager), we use greetd
    # Note: Autologin is configured per-host in hosts/<hostname>/desktop.nix
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command =
            "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd 'wayfire -c $(${xdgConfigResolver}/bin/xdg-config-resolve wayfire/wayfire.ini)'";
          user = "greeter";
        };
      };
    };

  }; # End of config = mkIf cfg.enable
}
