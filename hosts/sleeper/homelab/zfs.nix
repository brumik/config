{ config, lib, pkgs, ... }:
let
  cfg = config.homelab.zfs;
  hcfg = config.homelab;
in {
  options.homelab.zfs = { enable = lib.mkEnableOption "zfs"; };

  config = lib.mkIf cfg.enable {
    services.sanoid = {
      enable = true;
      interval = "hourly";
      templates.backup = {
        hourly = 72;
        daily = 30;
        monthly = 12;
        yearly = 1;
        autoprune = true;
        autosnap = true;
      };

      # We need to list all pools OR add recursive option to a dataset
      datasets."dpool/backup" = { useTemplate = [ "backup" ]; };
      datasets."dpool/media" = { useTemplate = [ "backup" ]; };
      datasets."dpool/photos" = { useTemplate = [ "backup" ]; };

      datasets."rpool/safe" = {
        useTemplate = [ "backup" ];
        # Entails safe/home and safe/persist
        recursive = true;
      };

      # We do not want /nix
      datasets."rpool/local/root" = { useTemplate = [ "backup" ]; };
    };

    services.zfs = {
      # The autoSnapshot is not configurable how many times run
      # this means that it wakes up all disks every 5 min, spinning
      # up the disks constantly.

      # Try to scrub and repair data every month once
      autoScrub.enable = true;

      # Run weekly trims 
      trim.enable = true;
    };

    services.zfs.zed = lib.mkIf hcfg.email.enable {
      settings = {
        ZED_DEBUG_LOG = "/tmp/zed.debug.log";
        ZED_EMAIL_ADDR = [ hcfg.email.addr ];
        ZED_EMAIL_PROG = lib.getExe pkgs.msmtp;
        ZED_EMAIL_OPTS = "@ADDRESS@";

        ZED_NOTIFY_INTERVAL_SECS = 3600;

        ##
        # Notification verbosity.
        #   If set to 0, suppress notification if the pool is healthy.
        #   If set to 1, send notification regardless of pool health.
        #
        ZED_NOTIFY_VERBOSE = true;

        ##
        # Turn on/off enclosure LEDs when drives get DEGRADED/FAULTED.  This works for
        # device mapper and multipath devices as well.  Your enclosure must be
        # supported by the Linux SES driver for this to work.
        #
        ZED_USE_ENCLOSURE_LEDS = true;

        ZED_SCRUB_AFTER_RESILVER = true;
      };

      # this option does not work; will return error
      enableMail = false;
    };
  };
}
