{ config, pkgs, ... }: {
  sops.secrets = { "n100/smtp-pass" = { }; };

  programs.msmtp = {
    enable = true;
    setSendmail = true;
    defaults = {
      aliases = "/etc/aliases";
      port = 465;
      tls = "on";
      auth = "login";
      tls_starttls = "off";
    };
    accounts = {
      default = {
        host = "smtp.m1.websupport.sk";
        passwordeval = "cat ${config.sops.secrets."n100/smtp-pass".path}";
        user = "sleeper@berky.me";
        from = "sleeper@berky.me";
      };
    };
  };

  environment.etc = {
    "aliases" = {
      text = ''
        root: levente.berky@gmail.com
      '';
      mode = "0644";
    };
  };

  services.zfs.zed = {
    settings = {
      ZED_DEBUG_LOG = "/tmp/zed.debug.log";
      ZED_EMAIL_ADDR = [ "root" ];
      ZED_EMAIL_PROG = "${pkgs.msmtp}/bin/msmtp";
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
}
