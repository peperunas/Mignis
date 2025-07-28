{
  description = "A Nix flake for Mignis firewall";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs { inherit system; };

          mignisPkg = pkgs.callPackage ./package.nix;
        in
        {
          packages = rec {
            mignis = mignisPkg;
            default = mignis;
          };
        })
    // {
      overlays.default = final: prev: {
        mignis = self.packages.${prev.system}.mignis;
      };

      nixosModules = rec {
        mignis = import ./mignis.nix;
        default = mignis;
      };
    };
}
