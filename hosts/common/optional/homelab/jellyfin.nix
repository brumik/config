{ config, lib, ... }:
let
  cfg = config.homelab.jellyfin;
in {
  options.homelab.jellyfin = {
    enable = lib.mkEnableOption "Jellyfin";
  };

  config = lib.mkIf cfg.enable {
    services.jellyfin = {
      enable = true; 
      user = config.homelab.user;
      group = config.homelab.group;
      # port is 8096
    };

    services.traefik = config.homelab.traefik.createRouter {
      name = "jellyfin";
      port = 8096;
    };

    homelab.backup.stateDirs = [
      "/var/lib/jellyfin"
    ];
  };
}
