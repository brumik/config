{ config, lib, ... }:
let cfg = config.homelab.jellyfin;
in {
  options.homelab.jellyfin = {
    enable = lib.mkEnableOption "Jellyfin";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "jellyfin";
      description = "The subdomain where the service will be served";
    };

    baseDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/jellyfin";
      description = "The absolute path where the service will store the important informations";
    };
  };

  config = lib.mkIf cfg.enable {
    services.jellyfin = {
      enable = true;
      user = config.homelab.user;
      group = config.homelab.group;
      dataDir = cfg.baseDir;
      # port is 8096
    };

    homelab.traefik.routes = [{
      host = cfg.domain;
      port = 8096;
    }];

    homelab.backup.stateDirs = [ cfg.baseDir ];

    homelab.homepage.app = [{
      Jellyfin = {
        icon = "jellyfin.png";
        href = "https://${cfg.domain}.${config.homelab.domain}";
        siteMonitor = "https://${cfg.domain}.${config.homelab.domain}";
        description = "Netflix and Spotify at home";
      };
    }];
  };
}
