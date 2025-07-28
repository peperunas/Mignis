{
  description = "A Nix flake for Mignis firewall";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {

        packages = rec {
          mignis = pkgs.python3Packages.buildPythonApplication {
            pname = "mignis";
            version = "0.9.5";

            src = ./.;

            propagatedBuildInputs = [ pkgs.python3Packages.ipaddr ];

            installPhase = ''
              mkdir -p $out/bin
              cp mignis.py $out/bin/mignis
              chmod +x $out/bin/mignis
            '';

            meta = with pkgs.lib; {
              description = "A semantic based tool for firewall configuration";
              homepage = "https://github.com/secgroup/Mignis";
              license = licenses.mit;
            };
          };

          nixosModules = {
            mignis = import ./mignis.nix {
              mignis-pkg = mignis;
            };

            default = mignis;
          };

          nixosModule = {
            mignis = import ./mignis.nix {
              mignis-pkg = mignis;
            };
          };
        };
      });
}
