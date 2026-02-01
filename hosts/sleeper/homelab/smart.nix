{ config, lib, pkgs, ... }:
let
  cfg = config.homelab.smart;
  hcfg = config.homelab;
  disks = config.mySystems.disks;
in {
  options.homelab.smart = { enable = lib.mkEnableOption "smart"; };

  config = lib.mkIf (hcfg.enable && cfg.enable) {
    services.smartd = {
      enable = true;
      # Turns on monitoring of all the things (see man 5 smartd.conf)
      # and SMART Automatic Offline Testing on startup, and schedules short self-tests daily, and long self-tests weekly.
      defaults.monitored = "-a -o on -s (S/../.././02|L/../../7/04)";
      devices = [
        { device = disks.rootDisk1; }
        { device = disks.rootDisk2; }
        { device = disks.dataDisk1; }
        { device = disks.dataDisk2; }
        { device = disks.dataSpare; }
        { device = disks.dataCache; }
      ];
      # Disable autodetect to avoid false negatives
      autodetect = false;
      # defaults.autodetected = "-a -o on -s (S/../.././02|L/../../7/04)";
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
