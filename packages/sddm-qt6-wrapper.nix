{ pkgs, ... }:

# Wrapper for SDDM to ensure sddm-greeter symlink exists
# This fixes the issue where SDDM looks for sddm-greeter but only sddm-greeter-qt6 exists
pkgs.symlinkJoin {
  name = "sddm-qt6-wrapper";
  paths = [ pkgs.kdePackages.sddm ];

  postBuild = ''
    # Create symlink from sddm-greeter to sddm-greeter-qt6 if it doesn't exist
    if [ ! -f $out/bin/sddm-greeter ] && [ -f $out/bin/sddm-greeter-qt6 ]; then
      ln -s sddm-greeter-qt6 $out/bin/sddm-greeter
    fi
  '';
}
