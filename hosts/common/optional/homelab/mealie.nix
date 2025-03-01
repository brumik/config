{ config, lib, ... }:
let
  cfg = config.homelab.mealie;
in {
  options.homelab.mealie = {
    enable = lib.mkEnableOption "mealie";
  };

  config = lib.mkIf cfg.enable {
    sops.secrets."n100/mealie-credentials" = { };

    # TODO: the current stable mealie is outdated (1.24 vs 2.x)
    services.mealie = {
      enable = true;
      listenAddress = "0.0.0.0";
      port = 9000;
      settings = {
        BASE_URL = "https://mealie.${config.homelab.domain}";
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
        OIDC_CONFIGURATION_URL = "https://authelia.${config.homelab.domain}/.well-known/openid-configuration";
        OIDC_CLIENT_ID = "mealie";
        OIDC_AUTO_REDIRECT = "false";
        OIDC_ADMIN_GROUP = "mealie_admin";
        OIDC_USER_GROUP = "mealie_user";
      };
      credentialsFile = config.sops.secrets."n100/mealie-credentials".path;
    };

    homelab.backup.stateDirs = [
      "/var/lib/mealie"
    ];

    networking.firewall.allowedTCPPorts = [ 9000 ];
  };
}
