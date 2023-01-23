{ inputs }:
{ pkgs, lib, config, ... }:

with lib;

let
  goesNotify = import ./goes-notify.nix { inherit pkgs; };
  cfg = config.services.goesNotify;
in
{
  imports = [
    "${inputs.home-manager}/nixos"
  ];

  options.services.goesNotify = {
    enable = mkEnableOption "Enable goes-notify service";

    enrollmentLocationId = mkOption {
      type = types.str;
      default = "5180";
      description = "The Trusted Traveler Program enrollment location";
    };

    appointmentDate = mkOption {
      type = types.str;
      default = "April 22, 2099";
      description = "The date of your appointment";
    };

    wrapperProgram = mkOption {
      type = types.functionTo types.str;
      default = prog: prog;
      description = "Function that takes the goes-notify and wraps it in a new command";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      goesNotify
    ];

    users.mutableUsers = false;
    users.users.goes-notify = {
      isSystemUser = true;
      group = "goes-notify";
      home = "/var/goes-notify";
    };

    users.groups.goes-notify = { };
    home-manager.users.goes-notify = {
      home.stateVersion = "22.11";
      home.username = "goes-notify";
      home.homeDirectory = "/var/goes-notify";

      xdg.configFile."systemd/user/goes-notify.service".source =
        pkgs.writeTextFile "goes-notify.service"
          (
            let runner =
              pkgs.writeShellScript "goes-notify-runner" ''
                ${goesNotify}/bin/goes-notify --location_id=${cfg.enrollmentLocationId} --interview_date="${cfg.appointmentDate}"
              '';
            in

            ''
              [Unit]
              After=network.target
              Description=goes-notify watcher

              [Service]
              DynamicUser=true
              ExecStart=${cfg.wrapperProgram "${runner}"}

              Group=goes-notify
              Restart=on-failure
              User=goes-notify
            ''
          );
    };
  };

  meta.maintainers = with lib.maintainers; [ ];
}
