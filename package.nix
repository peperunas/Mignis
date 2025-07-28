{ pkgs, src }:

pkgs.python3Packages.buildPythonApplication {
  pname = "mignis";
  version = "0.9.5";

  inherit src;

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
}
