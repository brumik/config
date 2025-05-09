{ config, lib, ... }:
let
  cfg = config.homelab.immich;
  dname = "${cfg.domain}.${config.homelab.domain}";
in {
  options.homelab.immich = {
    enable = lib.mkEnableOption "Immich";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "photos";
      description = "The subdomain where the service will be served";
    };

    baseDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/immich";
      description = "The absolute path where the service will store the important informations";
    };
  };

  config = lib.mkIf cfg.enable {
    services.immich = {
      enable = true;
      mediaLocation = cfg.baseDir;
      host = "127.0.0.1";
      port = 2283;
      environment = { IMMICH_TRUSTED_PROXIES = "127.0.0.1"; };
    };

    homelab.traefik.routes = [{
      host = cfg.domain;
      port = 2283;
    }];

    homelab.backup.stateDirs = [ cfg.baseDir ];

    homelab.homepage.app = [{
      Immich = {
        icon = "immich.png";
        href = "https://${dname}";
        siteMonitor = "https://${dname}";
        description = "Google photos at home";
      };
    }];

    homelab.authelia.oidc.clients = [{
      client_id = "immich";
      client_name = "immich";
      client_secret =
        "$pbkdf2-sha512$310000$iTqA/Ea6mzGKSOjj3q6OnQ$pHEqDjpQ/AtJWg0wMgPbYvP3laYVF7EKrLRJoKp4vTQOK8JIbPOOTApd.O0C5gucQ07lFKHO9WpxBVyvpduc6g";
      public = false;
      consent_mode = "implicit";
      authorization_policy = "one_factor";
      require_pkce = false;
      redirect_uris = [
        "https://${dname}/auth/login"
        "https://${dname}/user-settings"
        "app.immich:///oauth-callback"
      ];
      scopes = [ "openid" "email" "profile" ];
      userinfo_signed_response_alg = "none";
      token_endpoint_auth_method = "client_secret_post";
    }];
  };
}
