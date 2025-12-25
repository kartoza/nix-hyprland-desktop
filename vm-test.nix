# VM configuration for testing Kartoza Wayfire Desktop
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/virtualisation/qemu-vm.nix")
    ./modules/wayfire-desktop.nix
  ];

  # Enable Kartoza Wayfire Desktop with explicit configuration
  kartoza.wayfire-desktop = {
    enable = true;

    iconTheme = "Papirus";
    gtkTheme = "Adwaita";
    darkTheme = true;

    # Cursor configuration
    cursorTheme = "Vanilla-DMZ";
    cursorSize = 24;

    # Display scaling configuration
    fractionalScaling = 1.0; # 100% scaling for VM

    # Per-display scaling (useful for multi-monitor setups)
    displayScaling = {
      # Example configuration - these displays won't exist in VM but shows usage
      "eDP-1" = 1.0; # Laptop display at 100%
      "DP-1" = 1.0; # External monitor at 100%
      "HDMI-1" = 1.0; # External monitor at 100%
    };

    # Qt application theming
    qtTheme = "gnome"; # Options: gnome, gtk2, kde, fusion

    # Keyboard layout configuration (demonstrates customization)
    keyboardLayouts = [
      "us"
      "de"
      "fr"
    ]; # US, German, French (Alt+Shift to toggle)

    # Wallpaper configuration (demonstrates unified desktop/lock screen wallpaper)
    wallpaper = "/etc/kartoza-wallpaper.png"; # Default Kartoza wallpaper
    # wallpaper = "/home/testuser/Pictures/custom-wallpaper.jpg"; # Example custom path
  };

  # VM-specific configuration
  virtualisation = {
    memorySize = 4096; # 4GB RAM
    cores = 4;
    diskSize = 8192; # 8GB disk
    graphics = true;
    resolution = {
      x = 1920;
      y = 1080;
    };
    qemu.options = [
      "-vga virtio"
      "-display gtk,gl=on,grab-on-hover=on"
      "-device virtio-tablet-pci"
      "-device virtio-keyboard-pci"
    ];
  };

  # Basic system configuration for VM
  boot.loader.grub.device = "/dev/vda";

  # Enable networking
  networking = {
    hostName = "wayfire-test-vm";
    useDHCP = lib.mkDefault true;
  };

  # Create a test user
  users.users.testuser = {
    isNormalUser = true;
    password = "test"; # Simple password for VM testing
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "audio"
    ];
  };

  # Enable sudo for test user
  security.sudo.wheelNeedsPassword = false;

  # Basic services for VM testing
  services = {
    openssh.enable = true;
    # Disable some services that might cause issues in VM
    thermald.enable = lib.mkForce false;
  };

  # Minimal package set for testing
  environment.systemPackages = with pkgs; [
    firefox
    nautilus
    gnome-terminal
  ];

  # Auto-login for convenience in VM testing
  services.greetd.settings = {
    default_session = lib.mkForce {
      command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd 'wayfire -c /etc/xdg/wayfire/wayfire.ini'";
      user = "greeter";
    };
    initial_session = {
      command = "wayfire -c /etc/xdg/wayfire/wayfire.ini";
      user = "testuser";
    };
  };

  system.stateVersion = "25.05";
}
