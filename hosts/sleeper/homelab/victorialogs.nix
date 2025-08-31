{ config, lib, ... }:
let
  cfg = config.homelab.victorialogs;
  hcfg = config.homelab;
  baseDirDefaultVal = "/var/lib/victorialogs";
  dname = "${cfg.domain}.${hcfg.domain}";
in {
  options.homelab.victorialogs = {
    enable = lib.mkEnableOption "Victorialogs";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "victorialogs";
      description = "The subdomain where the service will be served";
    };

    baseDir = lib.mkOption {
      type = lib.types.path;
      default = baseDirDefaultVal;
      description = "The absolute path where the service will store the important informations";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = lib.mkIf (cfg.baseDir != baseDirDefaultVal) [
      "d ${cfg.baseDir} 0755 root root -"
      "L ${baseDirDefaultVal} - - - - ${cfg.baseDir}"
    ];

    services.victorialogs = {
      enable = true;
      listenAddress = "127.0.0.1:9428";
      stateDir = "victorialogs";
      extraOptions = [
        "-retentionPeriod=30d"
        "-loggerLevel=WARN"
      ];
    };

    homelab.traefik.routes = [{
      host = cfg.domain;
      port = 9428;
    }];

    homelab.homepage.admin = [{
      Victorialogs = {
        icon = "victorialogs.png";
        href = "https://${dname}";
        siteMonitor = "https://${dname}";
        description = "Monitoring tool";
      };
    }];
  };
}
