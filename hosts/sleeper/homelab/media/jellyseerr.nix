{ config, lib, ... }:
let
  cfg = config.homelab.media.jellyseerr;
  hcfg = config.homelab;
  baseDirDefaultVal = "/var/lib/jellyseerr";
  dname = "${cfg.domain}.${hcfg.domain}";
in {
  options.homelab.media.jellyseerr = {
    enable = lib.mkEnableOption "Jellyseerr";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "jellyseerr";
      description = "The subdomain where the service will be served";
    };

    baseDir = lib.mkOption {
      type = lib.types.path;
      default = baseDirDefaultVal;
      description = "The absolute path where the service will store the important informations";
    };
  };

  config = lib.mkIf (hcfg.enable && hcfg.media.enable && cfg.enable) {
    services.jellyseerr = {
      enable = true;
      configDir = "${cfg.baseDir}/config";
      port = 5055;
    };

    systemd.tmpfiles.rules = lib.mkIf (cfg.baseDir != baseDirDefaultVal) [
      "d ${cfg.baseDir} 0755 root root -"
      "L ${baseDirDefaultVal} - - - - ${cfg.baseDir}"
    ];

    homelab.traefik.routes = [{
      host = cfg.domain;
      port = 5055;
    }];

    homelab.authelia.localBypassDomains = [ dname ];

    homelab.backup.stateDirs = [ cfg.baseDir ];

    homelab.homepage.media = [{
      Jellyseerr = {
        icon = "jellyseerr.png";
        href = "https://${dname}";
        siteMonitor = "https://${dname}";
        description = "Media recommendations, just for you";
      };
    }];
  };
}
