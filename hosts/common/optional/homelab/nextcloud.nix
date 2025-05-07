{ config, lib, pkgs, ... }:
let
  cfg = config.homelab.nextcloud;
  dname = "drive.${config.homelab.domain}";
  rootDir = "/var/lib/nextcloud";
in {
  options.homelab.nextcloud = { enable = lib.mkEnableOption "Nextcloud"; };

  config = lib.mkIf cfg.enable {
    sops.secrets = {
      "n100/nextcloud/oidc-client-secret" = { };
      "n100/nextcloud/admin-password" = { owner = "nextcloud"; };
    };

    services.nextcloud = {
      enable = true;
      https = false;
      # Only increase one by one for migrations!!!!
      package = pkgs.nextcloud31;
      hostName = dname;
      config.adminpassFile =
        config.sops.secrets."n100/nextcloud/admin-password".path;
      config.dbtype = "pgsql";
      database.createLocally = true;
      configureRedis = true;
      home = rootDir;
      settings = {
        trusted_proxies = [ "127.0.0.1" ];
      };
      # extraApps = {
      #   memories = pkgs.fetchNextcloudApp {
      #     sha256 = "sha256-RLYquOE83xquzv+s38bahOixQ+y4UI6OxP9HfO26faI=";
      #     url =
      #       "https://github.com/pulsejet/nextcloud-oidc-login/releases/download/v3.2.2/oidc_login.tar.gz";
      #     license = lib.licenses.agpl3Only.shortName;
      #   };
      #
      # };
      # extraAppsEnable = true;
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

    homelab.authelia.exposedDomains = [ dname ];

    homelab.backup.stateDirs = [ rootDir ];

    homelab.homepage.app = [{
      Drive = {
        icon = "nextcloud.png";
        href = "https://${dname}";
        siteMonitor = "https://${dname}";
        description = "Google drive at home";
      };
    }];

    homelab.authelia.oidc.clients = [{
      client_id = "nextcloud";
      client_name = "Nextcloud";
      client_secret =
        "$pbkdf2-sha512$310000$RdFeq6sHkW1IG4M8EKM/VQ$.4RAqcLh5pkVJWjOwRzj.v0wGzJDH3y.tSkrcmLGfoCGIsZpUnwDsZFuarZ63UWAVQ2/aWuGete56j6zpWRhgQ";
      public = false;
      consent_mode = "implicit";
      authorization_policy = "one_factor";
      require_pkce = true;
      redirect_uris = [ "https://${dname}/apps/oidc_login/oidc" ];
      scopes = [ "openid" "email" "profile" "groups" ];
      userinfo_signed_response_alg = "none";
      token_endpoint_auth_method = "client_secret_post";
    }];
  };
}
