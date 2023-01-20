{ pkgs, lib, config, ... }:

with lib;

let
  goesNotify = import ./goes-notify.nix { inherit pkgs; };
  cfg = config.services.goesNotify;
in
{
  options.services.goesNotify = {
    enable = mkEnableOption "Enable goes-notify service";

    enrollmentLocationId = mkOption {
      type = types.string;
      default = "5180";
      description = "The Trusted Traveler Program enrollment location";
    };

    appointmentDate = mkOption {
      type = types.string;
      default = "April 22, 2099";
      description = "The date of your appointment";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      goesNotify
      vopono
    ];

    users.mutableUsers = false;
    users.users.goes-notify = {
      isSystemUser = true;
      group = "goes-notify";
      home = "/var/goes-notify";
    };

    users.groups.goes-notify = { };

    security.sudo.extraRules = [
      {
        users = [ "goes-notify" ];
        commands = [
          {
            command = "${vopono}/bin/vopono";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];

    systemd.services.goes-notify = {
      description = "goes-notify watcher";

      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ]; # if networking is needed

      restartIfChanged = true; # set to false, if restarting is problematic

      serviceConfig = {
        DynamicUser = true;
        ExecStart = ''
          ${goesNotify}/bin/goes-notify --location_id=${cfg.enrollmentLocationId} --interview_date="${cfg.appointmentDate}"
        '';
        Restart = "on-failure";
      };
    };
  };

  meta.maintainers = with lib.maintainers; [ ];
}
