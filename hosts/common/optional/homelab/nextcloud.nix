{ config, lib, pkgs, ... }:
let
  cfg = config.homelab.nextcloud;
  dname = "drive.${config.homelab.domain}";
  # Default media dir
  rootDir = "/var/lib/nextcloud";
in {
  # Other working setup: https://github.com/LongerHV/nixos-configuration/blob/91616669d15320662d2bee8e950ddaa4ca1154bc/modules/nixos/homelab/nextcloud.nix#L74
  options.homelab.nextcloud = { enable = lib.mkEnableOption "Nextcloud"; };

  config = lib.mkIf cfg.enable {
    environment.etc."nextcloud-admin-pass".text = "thisisalongpassword";

    services.nextcloud = {
      enable = true;
      https = true;
      # Only increase one by one for migrations!!!!
      package = pkgs.nextcloud31;
      hostName = dname;
      config.adminpassFile = "/etc/nextcloud-admin-pass";
      config.dbtype = "pgsql";
      database.createLocally = true;
      settings = {
        trusted_proxies = [ "127.0.0.1" ]; # trusted_domains = [ dname ];
      };
      configureRedis = true;
      home = rootDir;
    };

    # The nextcloud is PHP and the server is running on nginx service.
    services.nginx.virtualHosts."${dname}".listen = [{
      addr = "localhost";
      port = 11112;
    }];

    homelab.traefik.routes = [{
      host = "drive";
      port = 11112;
    }];

    # no need to backup the smb dir
    # homelab.backup.stateDirs = [ mediaDir ];

    homelab.homepage.app = [{
      Drive = {
        icon = "nextcloud.png";
        href = "https://${dname}";
        siteMonitor = "https://${dname}";
        description = "Google drive at home";
      };
    }];

    #   homelab.authelia.oidc.clients = [{
    #     client_id = "immich";
    #     client_name = "Immich";
    #     client_secret =
    #       "$pbkdf2-sha512$310000$zdze0iljXy76xeHihU7lbg$FDCjNnLuQ7qpDGzX03zFPuFUyGdiHE3OGEZvbD8/rXUp79HCFnGd1KflgUqWUXtthTRDCBch3IusTMAJzBkqRQ";
    #     public = false;
    #     consent_mode = "implicit";
    #     authorization_policy = "one_factor";
    #     require_pkce = false;
    #     redirect_uris = [
    #       "https://${dname}/auth/login"
    #       "https://${dname}/user-settings"
    #       "app.immich:///oauth-callback"
    #     ];
    #     scopes = [ "openid" "email" "profile" ];
    #     userinfo_signed_response_alg = "none";
    #   }];
    # };
  };
}
