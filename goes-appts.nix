{ pkgs ? import <nixpkgs> { } }:
pkgs.writeShellApplication {
  name = "goes-appts";
  text = builtins.readFile ./check.sh;
  runtimeInputs = [
    pkgs.curl
    pkgs.jq
    pkgs.coreutils
  ];
}
