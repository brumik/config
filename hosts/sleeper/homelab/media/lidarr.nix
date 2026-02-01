{ config, lib, ... }:
let
  cfg = config.homelab.media.lidarr;
  hcfg = config.homelab;
  baseDirDefaultVal = "/var/lib/lidarr";
  dname = "${cfg.domain}.${hcfg.domain}";
in {
  options.homelab.media.lidarr = {
    enable = lib.mkEnableOption "lidarr";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "lidarr";
      description = "The subdomain where the service will be served";
    };

    baseDir = lib.mkOption {
      type = lib.types.path;
      default = baseDirDefaultVal;
      description =
        "The absolute path where the service will store the important information";
    };
  };

  config = lib.mkIf (hcfg.enable && hcfg.media.enable && cfg.enable) {
    systemd.tmpfiles.rules = [
      "d ${hcfg.media.libDir}/music 0775 ${hcfg.user} ${hcfg.group} -"
    ];

    services.lidarr = {
      enable = true;
      user = hcfg.user;
      group = hcfg.group;
      settings.server.port = 8686;
      dataDir = cfg.baseDir;
    };

    homelab.traefik.routes = [{
      host = cfg.domain;
      port = 8686;
    }];

    homelab.backup.stateDirs = [ cfg.baseDir ];

    homelab.homepage.arr = [{
      Lidarr = {
        icon = "lidarr.png";
        href = "https://${dname}";
        siteMonitor = "https://${dname}";
        description = "Music search and fetcher";
      };
    }];
  };
}
