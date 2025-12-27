{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.kartoza.hyprland-desktop;

  # Use the icon theme from the module configuration
  iconThemeName = cfg.iconTheme;

in {
  options = {
    kartoza.hyprland-desktop = {
      enable = mkEnableOption "Kartoza Hyprland Desktop Environment";

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
        default = "qt5ct";
        description =
          "Qt platform theme to use for Qt applications (qt5ct, gnome, gtk2, kde, fusion)";
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
        description =
          "List of keyboard layouts (first layout is default, others accessible via Alt+Shift toggle)";
      };

      wallpaper = mkOption {
        type = types.str;
        default = "/etc/kartoza-wallpaper.png";
        example = "/home/user/Pictures/my-wallpaper.jpg";
        description =
          "Path to wallpaper image used for both desktop background and swaylock screen";
      };

      greetdTheme = mkOption {
        type = types.str;
        default = "regreet";
        example = "regreet";
        description = "Greetd greeter to use (regreet for GTK-based greeter)";
      };
    };
  };

  config = mkIf cfg.enable {

    # Deploy essential Hyprland dotfiles at system level
    # Enable Hyprland
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };

    # Enable NetworkManager service for network and VPN management
    networking.networkmanager.enable = true;

    # Enable polkit for permission management (required for nm-applet)
    security.polkit.enable = true;

    environment.systemPackages = with pkgs; [
      # Default icon theme (Papirus) - can be overridden by kartoza.nix or other configs
      papirus-icon-theme
      # Greetd and regreet
      regreet
      # Essential fonts for waybar and hyprland
      font-awesome # For waybar icons (required for waybar symbols)
      noto-fonts # Good fallback font family
      noto-fonts-cjk-sans # CJK character support
      noto-fonts-color-emoji # Emoji support
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
      # Keyboard layout detection
      xkblayout-state
      # Add these for better app compatibility
      audio-recorder
      blueman # Bluetooth manager with system tray
      bluez-tools # Command line tools for Bluetooth
      brightnessctl # Brightness control for waybar
      clipse # Wayland clipboard manager
      dmenu
      # Qt theming and configuration tools
      libsForQt5.qt5ct # Qt5 configuration tool for better theming control
      libsForQt5.qtstyleplugins # Additional Qt style plugins
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
      swww # Wallpaper setter (works with Hyprland too)
      util-linux # Provides rfkill tool to enable/disable wireless devices
      waybar # Bar panel for Wayland
      hyprpaper # Wallpaper utility for Hyprland
      wf-recorder # Wayland screen recorder
      wireplumber
      wl-clipboard
      wlr-randr # Display configuration for wlr compositors
      hyprshot # Screenshot tool for Hyprland
      wshowkeys # On-screen key display for Wayland (setuid wrapper configured below)
      wtype # Wayland typing utility
      wev # Wayland event viewer for debugging
      xdg-desktop-portal-gtk
      xdg-desktop-portal-hyprland # For screen sharing in Hyprland
      zenity # GUI dialogs for keyring unlock
      # Wallpaper and screen management
      swww # Efficient animated wallpaper daemon for wayland
      swayidle # Idle management daemon for Wayland
      swaylock # Screen locker for Wayland
      # Cursor theme
      vanilla-dmz # Default cursor theme
      # Image processing for wallpapers
      imagemagick # For creating default wallpaper
      # Deploy script for system-wide Hyprland config management
      jq # Required for waybar config building
      # Window management and switching
      hyprswitch # CLI/GUI that allows switching between windows in Hyprland
    ];

    environment.sessionVariables = {
      XDG_SESSION_TYPE = "wayland";
      # Let Hyprland set XDG_CURRENT_DESKTOP automatically to avoid compatibility warnings
      XDG_SESSION_DESKTOP = "hyprland";
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
        "$HOME/.config/hypr/scripts"
        "$HOME/.config/waybar/scripts"
        "$HOME/.config/scripts"
        "/etc/xdg/fuzzel"
        "/etc/xdg/hypr/scripts"
        "/etc/xdg/waybar/scripts"
        "/etc/xdg/scripts"
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

      # Qt scaling and sizing fixes to prevent dialog compression
      QT_AUTO_SCREEN_SCALE_FACTOR = "1";
      QT_ENABLE_HIGHDPI_SCALING = "1";
      QT_SCALE_FACTOR = toString cfg.fractionalScaling;
      QT_FONT_DPI = "96";
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

    # Deploy Hyprland configuration files system-wide using standard paths
    environment.etc = {
      # Deploy entire Hyprland configuration folder to /etc/xdg/hypr
      "xdg/hypr".source = ../dotfiles/hypr;
      "xdg/ml4w".source = ../dotfiles/ml4w;
      "xdg/waybar/style.css".source = ../dotfiles/waybar/style.css;
      # Build combined waybar config from modular JSON files  
      "xdg/waybar/config" = {
        source = pkgs.runCommand "waybar-config-hyprland" {
          nativeBuildInputs = [ pkgs.jq ];
        } ''
          src=${../dotfiles/waybar/config.d}

          # Use generic base config and add all modules including taskbar
          cat "$src/00-base.json" > config.json

          # Merge all other config fragments except base files
          for file in "$src"/*.json; do
            filename=$(basename "$file")
            # Skip base files
            if [[ "$filename" != "00-base.json" && "$filename" != "00-base-hyprland.json" ]]; then
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
      "xdg/mako/sounds/notification.wav".source =
        ../resources/sounds/notification.wav;
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
          configWithWallpaper =
            lib.replaceStrings [ "image=/etc/kartoza-wallpaper.png" ]
            [ "image=${cfg.wallpaper}" ] baseConfig;
        in configWithWallpaper;
      };
      # Fuzzel emoji script - standard location for executables
      "xdg/fuzzel/fuzzel-emoji".source = ../dotfiles/fuzzel/fuzzel-emoji;
      # Qt5ct configuration for proper dialog sizing
      "xdg/qt5ct/qt5ct.conf".source = ../dotfiles/qt5ct/qt5ct.conf;
      "xdg/qt5ct/qss/kartoza-qt-fixes.qss".source =
        ../dotfiles/qt5ct/qss/kartoza-qt-fixes.qss;
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

    # Configure setuid wrapper for wshowkeys to capture keyboard events
    security.wrappers.wshowkeys = {
      owner = "root";
      group = "input";
      permissions = "u+s,g+x";
      source = "${pkgs.wshowkeys}/bin/wshowkeys";
    };

    xdg.portal = {
      enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
        pkgs.xdg-desktop-portal-hyprland # For Hyprland screen sharing
      ];
      # Configure portal backends for Hyprland
      config = {
        hyprland = {
          default = lib.mkForce [ "gtk" "hyprland" ];
          "org.freedesktop.impl.portal.FileChooser" = lib.mkForce [ "gtk" ];
          "org.freedesktop.impl.portal.AppChooser" = lib.mkForce [ "gtk" ];
          "org.freedesktop.impl.portal.ScreenCast" = lib.mkForce [ "hyprland" ];
          "org.freedesktop.impl.portal.Screenshot" = lib.mkForce [ "hyprland" ];
        };
      };
      # Ensures the right backend is selected
      xdgOpenUsePortal = true;
    };

    # Configure default applications for MIME types
    environment.etc."xdg/mimeapps.list".text = ''
      [Default Applications]
      application/pdf=org.gnome.Evince.desktop
      text/plain=org.gnome.TextEditor.desktop
      image/jpeg=org.gnome.eog.desktop
      image/png=org.gnome.eog.desktop
      inode/directory=org.gnome.Nautilus.desktop
      application/x-gnome-saved-search=org.gnome.Nautilus.desktop

      [Added Associations]
      application/pdf=org.gnome.Evince.desktop
      inode/directory=org.gnome.Nautilus.desktop
      application/x-gnome-saved-search=org.gnome.Nautilus.desktop
    '';

    # Import environment variables into systemd user session
    systemd.user.extraConfig = ''
      DefaultEnvironment="WAYLAND_DISPLAY=wayland-1"
      DefaultEnvironment="XDG_SESSION_DESKTOP=hyprland"
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

    # Enable greetd display manager with regreet greeter
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.regreet}/bin/regreet";
          user = "greeter";
        };
      };
    };

    # Configure regreet
    programs.regreet = {
      enable = true;
      settings = {
        background = {
          path = cfg.wallpaper;
          fit = "Cover";
        };
        appearance = { greeting_msg = "Welcome to Kartoza"; };
        GTK = {
          application_prefer_dark_theme = mkDefault cfg.darkTheme;
          cursor_theme_name = mkDefault cfg.cursorTheme;
          cursor_theme_size = mkDefault cfg.cursorSize;
          icon_theme_name = mkDefault iconThemeName;
          theme_name = mkDefault cfg.gtkTheme;
        };
      };
    };

  }; # End of config = mkIf cfg.enable
}
