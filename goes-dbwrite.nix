{ pkgs ? import <nixpkgs> { } }:
pkgs.writeShellApplication {
  name = "goes-dbwrite";
  text = builtins.readFile ./dbwrite.sh;
  runtimeInputs = [
    pkgs.sqlite
  ];
}
