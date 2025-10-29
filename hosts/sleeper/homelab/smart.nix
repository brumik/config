{ config, lib, pkgs, ... }:
let
  cfg = config.homelab.smart;
in {
  options.homelab.smart = { enable = lib.mkEnableOption "smart"; };

  config = lib.mkIf cfg.enable {
    services.smartd = {
      enable = true;
      # Turns on monitoring of all the things (see man 5 smartd.conf)
      # and SMART Automatic Offline Testing on startup, and schedules short self-tests daily, and long self-tests weekly.
      defaults.monitored = "-a -o on -s (S/../.././02|L/../../7/04)";
      defaults.autodetected = "-a -o on -s (S/../.././02|L/../../7/04)";
      notifications = {
        mail = {
          enable = true;
          recipient = "root";
          sender = "sleeper@berky.me";
          mailer = lib.getExe pkgs.msmtp;
        };
        test = true;
      };
    };
  };
}
