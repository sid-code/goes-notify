{ pkgs ? import <nixpkgs> {} }:
let
  pushbulletChannel = "goes-notifications-lax";
in
pkgs.writeShellScriptBin "notify.sh" ''
token=$(<$HOME/.config/pushbullet/token)
${pkgs.curl}/bin/curl --header 'Access-Token: '$token \
     --header 'Content-Type: application/json' \
     --data-binary "{\"body\":\"FOUND $1 BEFORE $2\",\"title\":\"NEW APPT\",\"type\":\"note\",\"channel_tag\":\"${pushbulletChannel}\"}" \
     --request POST \
     https://api.pushbullet.com/v2/pushes
''
