{ pkgs ? import <nixpkgs> {} }:
let
  pushbulletToken = pkgs.lib.removeSuffix "\n" (builtins.readFile ./pushbullet-token);
  pushbulletChannel = "goes-notifications-lax";
in
pkgs.writeShellScriptBin "notify.sh" ''
${pkgs.curl}/bin/curl --header 'Access-Token: ${pushbulletToken}' \
     --header 'Content-Type: application/json' \
     --data-binary "{\"body\":\"FOUND $1 BEFORE $2\",\"title\":\"NEW APPT\",\"type\":\"note\",\"channel_tag\":\"${pushbulletChannel}\"}" \
     --request POST \
     https://api.pushbullet.com/v2/pushes
''
