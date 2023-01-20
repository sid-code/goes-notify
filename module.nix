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

    security.sudo.extraRules = [
      {
        users = [ "goes-notify" ];
        commands = [
          # {
          #   command = "...";
          #   options = [ "NOPASSWD" ];
          # }
        ];
      }
    ];

    systemd.services.init-goes-notify-home = {
      description = "Initialize goes-notify home directory";

      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "goes-notify-home-init" ''
          ${pkgs.coreutils}/bin/mkdir -p /var/goes-notify
          ${pkgs.coreutils}/bin/chown goes-notify /var/goes-notify
        '';
      };
    };

    systemd.services.goes-notify = {
      description = "goes-notify watcher";

      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ]; # if networking is needed

      restartIfChanged = true; # set to false, if restarting is problematic

      serviceConfig = {
        User = "goes-notify";
        Group = "goes-notify";
        DynamicUser = true;
        ExecStart = cfg.wrapperProgram pkgs.writeShellScript "goes-notify-runner" ''
          ${goesNotify}/bin/goes-notify --location_id=${cfg.enrollmentLocationId} --interview_date="${cfg.appointmentDate}"
        '';
        Restart = "on-failure";
      };
    };
  };

  meta.maintainers = with lib.maintainers; [ ];
}
