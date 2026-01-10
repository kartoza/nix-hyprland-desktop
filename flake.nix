{
  description = "Kartoza Hyprland Desktop Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  };

  outputs =
    {
      self,
      nixpkgs,
      ...
    }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      # Export the Hyprland desktop module
      nixosModules = {
        hyprland-desktop = import ./modules/hyprland-desktop.nix;
        default = self.nixosModules.hyprland-desktop;
      };

      # VM configurations for testing
      nixosConfigurations = {
        vm-test = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./vm-test.nix ];
        };
      };

      # Development shell
      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            name = "hyprland-config-dev";
            buildInputs = with pkgs; [
              nixfmt-rfc-style
              git
            ];
          };
        }
      );

      # Formatter for nix files
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);
    };
}
