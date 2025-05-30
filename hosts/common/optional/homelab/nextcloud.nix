{ config, lib, pkgs, ... }:
let
  cfg = config.homelab.nextcloud;
  hcfg = config.homelab;
  dname = "drive.${hcfg.domain}";
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
        "allow_user_to_change_display_name" = false;
        "lost_password_link" = "disabled";
        "oidc_login_provider_url" = "https://${hcfg.authelia.domain}.${hcfg.domain}";
        "oidc_login_client_id" = "nextcloud";
        "oidc_login_client_secret" = "insecure_secret";
        "oidc_login_auto_redirect" = false;
        "oidc_login_end_session_redirect" = false;
        "oidc_login_button_text" = "Log in with Authelia";
        "oidc_login_hide_password_form" = false;
        "oidc_login_use_id_token" = false;
        "oidc_login_attributes" = {
          "id" = "preferred_username";
          "name" = "name";
          "mail" = "email";
          "groups" = "groups";
        };
        "oidc_login_default_group" = "oidc";
        "oidc_login_use_external_storage" = false;
        "oidc_login_scope" = "openid profile email groups";
        "oidc_login_proxy_ldap" = false;
        "oidc_login_disable_registration" = false;
        "oidc_login_redir_fallback" = false;
        "oidc_login_tls_verify" = true;
        "oidc_create_groups" = false;
        "oidc_login_webdav_enabled" = false;
        "oidc_login_password_authentication" = false;
        "oidc_login_public_key_caching_time" = 86400;
        "oidc_login_min_time_between_jwks_requests" = 10;
        "oidc_login_well_known_caching_time" = 86400;
        "oidc_login_update_avatar" = false;
        "oidc_login_code_challenge_method" = "S256";
      };
      extraApps = {
        oidc_login = pkgs.fetchNextcloudApp {
          sha256 = "sha256-RLYquOE83xquzv+s38bahOixQ+y4UI6OxP9HfO26faI=";
          url =
            "https://github.com/pulsejet/nextcloud-oidc-login/releases/download/v3.2.2/oidc_login.tar.gz";
          license = lib.licenses.agpl3Only.shortName;
        };

      };
      extraAppsEnable = true;
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
        "$pbkdf2-sha512$310000$c8p78n7pUMln0jzvd4aK4Q$JNRBzwAo0ek5qKn50cFzzvE9RXV88h1wJn5KGiHrD0YKtZaR/nCb2CJPOsKaPK0hjf.9yHxzQGZziziccp6Yng";
      public = false;
      consent_mode = "implicit";
      authorization_policy = "one_factor";
      require_pkce = true;
      pkce_challenge_method = "S256";
      redirect_uris = [ "https://${dname}/apps/oidc_login/oidc" ];
      scopes = [ "openid" "email" "profile" "groups" ];
      userinfo_signed_response_alg = "none";
      token_endpoint_auth_method = "client_secret_basic";
    }];
  };
}
