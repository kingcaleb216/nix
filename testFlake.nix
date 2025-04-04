{
  description = "Syntax test";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: {
    nixosConfigurations.default = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ({ config, pkgs, ... }: {
          system.stateVersion = "24.05";
        }),

        ({ config, pkgs, ... }: {
          home-manager.useGlobalPkgs = true;
        })
      ];
    };
  };
}

