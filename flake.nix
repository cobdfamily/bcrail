{
  description = "bcrail: Flatcar + Incus helper tooling";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = f:
        nixpkgs.lib.genAttrs systems (system:
          f {
            pkgs = import nixpkgs {
              inherit system;
              overlays = [ self.overlays.default ];
            };
          });
    in
    {
      overlays.default = final: prev: {
        bcrail = final.callPackage ./nix/package.nix { };
      };

      packages = forAllSystems ({ pkgs }: {
        default = pkgs.bcrail;
        bcrail = pkgs.bcrail;
      });

      apps = forAllSystems ({ pkgs }: {
        default = {
          type = "app";
          program = "${pkgs.bcrail}/bin/bcrail";
        };
        bcrail = {
          type = "app";
          program = "${pkgs.bcrail}/bin/bcrail";
        };
      });

      nixosModules.default = import ./nix/module.nix;
    };
}
