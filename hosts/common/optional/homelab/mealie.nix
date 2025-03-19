{ config, lib, ... }:
let
  cfg = config.homelab.mealie;
  dir = "/var/lib/oci-mealie";
  dname = "mealie.${config.homelab.domain}";
in {
  options.homelab.mealie = { enable = lib.mkEnableOption "mealie"; };

  config = lib.mkIf cfg.enable {
    # sops.secrets = {
    #   "n100/mealie/oidc-client-secret" = {};
    #   "n100/mealie/smtp-pass" = {};
    # };
    #
    # TODO: the current stable mealie is outdated (1.24 vs 2.x)
    # services.mealie = {
    #   enable = true;
    #   listenAddress = "0.0.0.0";
    #   port = 9000;
    #   settings = {
    #     BASE_URL = "https://mealie.${config.homelab.domain}";
    #     ALLOW_SIGNUP = "false";
    #     LOG_LEVEL = "ERROR";
    #     # LOG_LEVEL = "DEBUG";
    #
    #     # =====================================;
    #     # Email Configuration;
    #     SMTP_HOST = "smtp.m1.websupport.sk";
    #     SMTP_PORT = "465";
    #     SMTP_FROM_NAME = "Mealie";
    #     SMTP_AUTH_STRATEGY = "SSL";
    #     SMTP_FROM_EMAIL = "mealie-noreply@berky.me";
    #     SMTP_USER = "mealie-noreply@berky.me";
    #
    #     DB_ENGINE = "sqlite";
    #     # =====================================;
    #     # SSO Configuration;
    #     OIDC_AUTH_ENABLED = "true";
    #     OIDC_SIGNUP_ENABLED = "true";
    #     OIDC_CONFIGURATION_URL = "https://authelia.${config.homelab.domain}/.well-known/openid-configuration";
    #     OIDC_CLIENT_ID = "mealie";
    #     OIDC_AUTO_REDIRECT = "false";
    #     OIDC_ADMIN_GROUP = "mealie_admin";
    #     OIDC_USER_GROUP = "mealie_user";
    #   };
    #   credentialsFile = config.sops.secrets."n100/mealie-credentials".path;
    # };
    #
    # homelab.backup.stateDirs = [
    #   "/var/lib/mealie"
    # ];
    # networking.firewall.allowedTCPPorts = [ 9000 ];

    sops.secrets = {
      "n100/mealie/oidc-client-secret" = { };
      "n100/mealie/smtp-pass" = { };
    };

    sops.templates."n100/mealie/.env" = {
      content = ''
        OIDC_CLIENT_SECRET=${
          config.sops.placeholder."n100/mealie/oidc-client-secret"
        }
        SMTP_PASSWORD=${config.sops.placeholder."n100/mealie/smtp-pass"}
      '';
      owner = config.homelab.user;
    };

    virtualisation.oci-containers.containers.mealie = {
      image = "ghcr.io/mealie-recipes/mealie:latest";
      ports = [ "9000:9000" ];
      volumes = [ "${dir}:/app/data" ];
      environment = {
        # A timezone http://php.net/timezones (default is UTC)
        TZ = "${config.time.timeZone}";
        PUID =
          builtins.toString config.users.users."${config.homelab.user}".uid;
        PGID =
          builtins.toString config.users.groups."${config.homelab.group}".gid;

        BASE_URL = "https://${dname}";
        ALLOW_SIGNUP = "false";
        LOG_LEVEL = "ERROR";
        # LOG_LEVEL = "DEBUG";

        # =====================================;
        # Email Configuration;
        SMTP_HOST = "smtp.m1.websupport.sk";
        SMTP_PORT = "465";
        SMTP_FROM_NAME = "Mealie";
        SMTP_AUTH_STRATEGY = "SSL";
        SMTP_FROM_EMAIL = "mealie-noreply@berky.me";
        SMTP_USER = "mealie-noreply@berky.me";

        DB_ENGINE = "sqlite";
        # =====================================;
        # SSO Configuration;
        OIDC_AUTH_ENABLED = "true";
        OIDC_SIGNUP_ENABLED = "true";
        OIDC_CONFIGURATION_URL =
          "https://authelia.${config.homelab.domain}/.well-known/openid-configuration";
        OIDC_CLIENT_ID = "mealie";
        OIDC_AUTO_REDIRECT = "true";
        OIDC_ADMIN_GROUP = "mealie_admin";
        OIDC_USER_GROUP = "mealie_user";
      };
      environmentFiles = [ config.sops.templates."n100/mealie/.env".path ];
    };

    homelab.traefik.routes = [{
      host = "mealie";
      port = 9000;
    }];

    homelab.authelia.exposedDomains = [ dname ];

    homelab.authelia.oidc.clients = [{
      client_id = "mealie";
      client_name = "Mealie";
      client_secret =
        "$pbkdf2-sha512$310000$VZKQTEyh9Dksw6uio6HMFA$HCMHsoYcSOx.2bwt7DM6IXk1MNi0ng2WU.I83KcVCzE16.voP4HPoh58AO.ltLLiLvdzroZ0oxD23XAkvs925A";
      public = false;
      consent_mode = "implicit";
      authorization_policy = "one_factor";
      require_pkce = true;
      pkce_challenge_method = "S256";
      redirect_uris = [ "https://${dname}/login" ];
      scopes = [ "openid" "email" "profile" "groups" ];
      userinfo_signed_response_alg = "none";
    }];

    homelab.backup.stateDirs = [ dir ];

    homelab.homepage.app = [{
      Mealie = {
        icon = "mealie.png";
        href = "https://${dname}";
        siteMonitor = "https://${dname}";
        description = "Recipe manager";
      };
    }];
  };
}
