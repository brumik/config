{ config, lib, ... }:
let
  cfg = config.homelab.mealie;
  dname = "mealie.${config.homelab.domain}";
  baseDirDefaultVal = "/var/lib/mealie";
in {
  options.homelab.mealie = {
    enable = lib.mkEnableOption "mealie";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "mealie";
      description = "The subdomain where the service will be served";
    };

    baseDir = lib.mkOption {
      type = lib.types.path;
      default = baseDirDefaultVal;
      description = "The absolute path where the service will store the important informations";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = lib.mkIf (cfg.baseDir != baseDirDefaultVal) [
      "d ${cfg.baseDir} 0755 root root -"
      "L ${baseDirDefaultVal} - - - - ${cfg.baseDir}"
    ];

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

    services.mealie = {
      enable = true;
      listenAddress = "127.0.0.1";
      port = 9000;
      settings = {
        PUID = 63892;
        PGID = 63892;
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
          "https://${config.homelab.authelia.domain}.${config.homelab.domain}/.well-known/openid-configuration";
        OIDC_CLIENT_ID = "mealie";
        OIDC_AUTO_REDIRECT = "true";
        OIDC_ADMIN_GROUP = "mealie_admin";
        OIDC_USER_GROUP = "mealie_user";
      };
      credentialsFile = config.sops.templates."n100/mealie/.env".path;
    };

    # Need to add private here since mealie service is already doing a symlink to it and we cannot follow it
    homelab.backup.stateDirs = [ cfg.baseDir "/var/lib/private/mealie" ];

    homelab.traefik.routes = [{
      host = cfg.domain;
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
