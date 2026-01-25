# VM configuration for testing Kartoza Hyprland Desktop
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
    ./modules/hyprland-desktop.nix
  ];

  # Enable Kartoza Hyprland Desktop with explicit configuration
  kartoza.hyprland-desktop = {
    enable = true;

    iconTheme = "Papirus";
    gtkTheme = "Adwaita";
    darkTheme = true;

    # Cursor configuration
    cursorTheme = "Vanilla-DMZ";
    cursorSize = 24;

    # Display scaling configuration
    fractionalScaling = 1.0; # 100% scaling for VM

    # Per-display scaling - configure for VM display
    displayScaling = {
      "Virtual-1" = 1.0; # QEMU virtual display
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
    # Defaults to Kartoza branded wallpaper, can be overridden with custom image:
    # wallpaper = /path/to/custom-wallpaper.jpg;
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
      "-display gtk,grab-on-hover=on,show-cursor=on"
      "-device virtio-tablet-pci"
      "-device virtio-keyboard-pci"
      "-device virtio-serial-pci"
      "-M accel=kvm"
    ];
  };

  # Basic system configuration for VM
  boot.loader.grub.device = "/dev/vda";

  # Enable networking
  networking = {
    hostName = "hyprland-test-vm";
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

  # Auto-login disabled to test SDDM theme
  # services.displayManager.autoLogin = {
  #   enable = true;
  #   user = "testuser";
  # };

  system.stateVersion = "25.05";
}
