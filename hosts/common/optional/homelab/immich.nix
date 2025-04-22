{ config, lib, ... }:
let cfg = config.homelab.immich;
in {
  options.homelab.immich = { enable = lib.mkEnableOption "Immich"; };

  config = lib.mkIf cfg.enable {
    services.immich = {
      enable = true;
      # mediaLocation = "/var/lib/immich";
      host = "127.0.0.1";
      port = 2283;
      environment = {
        IMMICH_TRUSTED_PROXIES = "127.0.0.1";
      };
    };

    homelab.traefik.routes = [{
      host = "photos";
      port = 2283;
    }];

    homelab.backup.stateDirs = [ "/var/lib/immich" ];

    homelab.homepage.app = [{
      Immich = {
        icon = "immich.png";
        href = "https://photos.${config.homelab.domain}";
        siteMonitor = "https://photos.${config.homelab.domain}";
        description = "Google photos at home";
      };
    }];
  };
}
