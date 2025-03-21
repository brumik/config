{ config, lib, ... }:
let cfg = config.homelab.jellyfin;
in {
  options.homelab.jellyfin = { enable = lib.mkEnableOption "Jellyfin"; };

  config = lib.mkIf cfg.enable {
    services.jellyfin = {
      enable = true;
      user = config.homelab.user;
      group = config.homelab.group;
      # port is 8096
    };

    homelab.traefik.routes = [{
      host = "jellyfin";
      port = 8096;
    }];

    homelab.backup.stateDirs = [ "/var/lib/jellyfin" ];


    homelab.homepage.app = [{
      Jellyfin = {
        icon = "jellyfin.png";
        href = "https://jellyfin.${config.homelab.domain}";
        siteMonitor = "https://jellyfin.${config.homelab.domain}";
        description = "Netflix and Spotify at home";
      };
    }];
  };
}
