{ pkgs ? import <nixpkgs> {} }:
let
  my-python-packages = p: with p; [
    requests
  ];
  my-python = pkgs.python3.withPackages my-python-packages;

  notifyScript = import ./notify-script { inherit pkgs; };

  watcher = pkgs.concatTextFile {
    name = "goes-watcher";
    files = [ ./goes-notify.py ];
  };

  config = pkgs.concatTextFile {
    name = "goes-config";
    files = [ ./config.json ];
  };
in
pkgs.writeShellScriptBin "goes-notify" ''
set -e
${my-python}/bin/python ${watcher} --notify_program=${notifyScript}/bin/notify.sh "$*"
''
