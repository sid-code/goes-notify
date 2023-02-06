{ pkgs, ... }:
pkgs.writeShellApplication {
  name = "goes-dbread";
  text = ''
    sqlite3 "$1" <<EOF
      SELECT datetime(time, "unixepoch"), location, datetime(seen, "unixepoch")
      FROM finds
      ORDER BY time DESC
      LIMIT 20
    EOF
  '';
  runtimeInputs = [
    pkgs.sqlite
  ];
}
