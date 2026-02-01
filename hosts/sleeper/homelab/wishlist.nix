{ config, lib, ... }:
let
  cfg = config.homelab.wishlist;
  dname = "${cfg.domain}.${config.homelab.domain}";
in {
  options.homelab.wishlist = {
    enable = lib.mkEnableOption "wishlist";
    domain = lib.mkOption {
      type = lib.types.str;
      default = "wishlist";
      description = "The subdomain where the service will be served";
    };
    baseDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/oci-wishlist";
      description = "The absolute path where the service will store important information";
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d ${cfg.baseDir} 0755 - - -"
      "d ${cfg.baseDir}/uploads 0755 - - -"
      "d ${cfg.baseDir}/data 0755 - - -"
    ];

    virtualisation.oci-containers.containers.wishlist = {
      image = "ghcr.io/cmintey/wishlist:latest";
      pull = "always";
      ports = [ "3280:3280" ];
      volumes = [
        "${cfg.baseDir}/uploads:/usr/src/app/uploads"
        "${cfg.baseDir}/data:/usr/src/app/data"
      ];
      environment = {
        ORIGIN = "https://${dname}";
        TOKEN_TIME = "72";
        DEFAULT_CURRENCY = "EUR";
        HEADER_AUTH_ENABLED = "true";
        HEADER_USERNAME = "Remote-User";
        HEADER_NAME = "Remote-Name";
        HEADER_EMAIL = "Remote-Email";
      };
    };
    
    homelab.traefik.routes = [{
      host = cfg.domain;
      port = 3280;
    }];

    homelab.backup.stateDirs = [ cfg.baseDir ];

    homelab.authelia.exposedDomains = [ dname ];

    homelab.homepage.app = [{
      Wishlist = {
        icon = "https://github.com/cmintey/wishlist/blob/main/static/android-chrome-512x512.png?raw=true";
        href = "https://${dname}";
        siteMonitor = "https://${dname}";
        description = "Wishlist service";
      };
    }];
  };
}
