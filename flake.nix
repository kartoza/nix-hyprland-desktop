{
  description = "Kartoza Hyprland Desktop Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    # Use hyprland-plugins flake for version-matched plugins
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
    # Use Hyprland flake directly for proper plugin compatibility
    hyprland.url = "github:hyprwm/Hyprland";
  };

  outputs = { self, nixpkgs, hyprland, hyprland-plugins, ... }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in {
      # Export the Hyprland desktop module
      nixosModules = {
        hyprland-desktop = { pkgs, ... }: {
          imports =
            [ ./modules/hyprland-desktop.nix hyprland.nixosModules.default ];
          # Pass hyprland-plugins to the module via overlay
          nixpkgs.overlays = [
            (final: prev: {
              hyprlandPluginsFromFlake =
                hyprland-plugins.packages.${pkgs.system};
            })
          ];
        };
        default = self.nixosModules.hyprland-desktop;
      };

      # VM configurations for testing
      nixosConfigurations = {
        vm-test = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            hyprland.nixosModules.default
            {
              nixpkgs.overlays = [
                (final: prev: {
                  hyprlandPluginsFromFlake =
                    hyprland-plugins.packages.x86_64-linux;
                })
              ];
            }
            ./vm-test.nix
          ];
        };
      };

      # Development shell
      devShells = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in {
          default = pkgs.mkShell {
            name = "hyprland-config-dev";
            buildInputs = with pkgs; [ nixfmt-rfc-style git ];
          };
        });

      # Formatter for nix files
      formatter = forAllSystems
        (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);
    };
}
