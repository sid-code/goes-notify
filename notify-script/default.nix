{ pkgs ? import <nixpkgs> {} }:
let pushbulletToken = builtins.readFile ./pushbulletToken;
in
pkgs.writeShellScriptBin "notify.sh" ''
${pkgs.curl}/bin/curl --header 'Access-Token: ${pushbulletToken}' \
     --header 'Content-Type: application/json' \
     --data-binary "{\"body\":\"FOUND $1 BEFORE $2\",\"title\":\"NEW APPT\",\"type\":\"note\"}" \
     --request POST \
     https://api.pushbullet.com/v2/pushes
''
