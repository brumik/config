{ config, lib, ... }:
let
  cfg = config.homelab.media.sonarr;
  hcfg = config.homelab;
  baseDirDefaultVal = "/var/lib/sonarr";
  dname = "${cfg.domain}.${hcfg.domain}";
in {
  options.homelab.media.sonarr = {
    enable = lib.mkEnableOption "sonarr";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "sonarr";
      description = "The subdomain where the service will be served";
    };

    baseDir = lib.mkOption {
      type = lib.types.path;
      default = baseDirDefaultVal;
      description =
        "The absolute path where the service will store the important informations";
    };
  };

  config = lib.mkIf (hcfg.enable && hcfg.media.enable && cfg.enable) {
    systemd.tmpfiles.rules = [
      "d ${hcfg.media.libDir}/shows 0775 ${hcfg.user} ${hcfg.group} -"
    ];

    services.sonarr = {
      enable = true;
      user = hcfg.user;
      group = hcfg.group;
      settings.server.port = 8989;
      dataDir = cfg.baseDir;
    };

    homelab.traefik.routes = [{
      host = cfg.domain;
      port = 8989;
    }];

    homelab.backup.stateDirs = [ cfg.baseDir ];

    homelab.homepage.arr = [{
      Sonarr = {
        icon = "sonarr.png";
        href = "https://${dname}";
        siteMonitor = "https://${dname}";
        description = "Movies search and fetcher";
      };
    }];
  };
}
