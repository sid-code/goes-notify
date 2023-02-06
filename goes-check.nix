{ pkgs ? import <nixpkgs> { } }:
pkgs.writeShellApplication {
  name = "goes-check";
  text = ''
    goes-appts "$1" | goes-dbwrite "$2"
  '';
  runtimeInputs = [
    self.packages.x86_64-linux.goes-appts
    self.packages.x86_64-linux.goes-dbwrite
  ];
}
