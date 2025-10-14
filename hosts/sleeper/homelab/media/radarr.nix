{ config, lib, ... }:
let
  cfg = config.homelab.media.radarr;
  hcfg = config.homelab;
  baseDirDefaultVal = "/var/lib/radarr";
  dname = "${cfg.domain}.${hcfg.domain}";
in {
  options.homelab.media.radarr = {
    enable = lib.mkEnableOption "radarr";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "radarr";
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
      "d ${hcfg.media.libDir}/movies 0775 ${hcfg.user} ${hcfg.group} -"
    ];

    services.radarr = {
      enable = true;
      user = hcfg.user;
      group = hcfg.group;
      settings.server.port = 7878;
      dataDir = cfg.baseDir;
    };

    homelab.traefik.routes = [{
      host = cfg.domain;
      port = 7878;
    }];

    homelab.backup.stateDirs = [ cfg.baseDir ];

    homelab.homepage.arr = [{
      Radarr = {
        icon = "radarr.png";
        href = "https://${dname}";
        siteMonitor = "https://${dname}";
        description = "Movies search and fetcher";
      };
    }];
  };
}
