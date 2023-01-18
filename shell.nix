{ pkgs ? import <nixpkgs> {} }:
let
  my-python-packages = p: with p; [
    requests
  ];
  my-python = pkgs.python3.withPackages my-python-packages;
in my-python.env
