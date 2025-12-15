# VM configuration for testing Kartoza Wayfire Desktop
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/virtualisation/qemu-vm.nix")
    ./modules/wayfire-desktop.nix
  ];

  # Enable Kartoza Wayfire Desktop
  kartoza.wayfire-desktop.enable = true;

  # VM-specific configuration
  virtualisation = {
    memorySize = 4096; # 4GB RAM
    cores = 4;
    diskSize = 8192; # 8GB disk
    graphics = true;
    resolution = { x = 1920; y = 1080; };
    qemu.options = [
      "-vga virtio"
      "-display gtk,gl=on"
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
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
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
