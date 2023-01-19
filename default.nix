{ pkgs, lib, config, ... }:

with lib;

let
  goes-notify = import ./goes-notify { inherit pkgs; };
  cfg = config.services.fusuma;
in {
  options.services.goes-notify = {
    enable = mkEnableOption "Enable goes-notify service";

    package = mkOption {
      type = types.package;
      default = goes-notify;
      defaultText = "<goes-notify>";
      description = "Set version of goes-notify package to use.";
    };

    enrollmentLocationId = mkOption {
      type = types.int;
      default = 5180;
      description = "The Trusted Traveler Program enrollment location";
    };

    appointmentDate = mkOption {
      type = types.string;
      default = "April 22, 2099";
      description = "The date of your appointment";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ]; # if user should have the command available as well

    systemd.services.fusuma = {
      description = "goes-notify watcher";

      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ]; # if networking is needed

      restartIfChanged = true; # set to false, if restarting is problematic

      serviceConfig = {
        DynamicUser = true;
        ExecStart = "${cfg.package}/bin/goes-notify";
        Restart = "on-failure";
      };
    };
  };

  meta.maintainers = with lib.maintainers; [  ];
}
