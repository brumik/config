{ config, lib, pkgs, ... }:
let
  cfg = config.homelab.nextcloud;
  hcfg = config.homelab;
  dname = "${cfg.domain}.${hcfg.domain}";
  baseDirDefaultVal = "/var/lib/nextcloud";
  dbname = "nextcloud";
  servicename = "phpfpm-nextcloud";
in {
  options.homelab.nextcloud = {
    enable = lib.mkEnableOption "Nextcloud";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "drive";
      description = "The subdomain where the service will be served";
    };

    baseDir = lib.mkOption {
      type = lib.types.path;
      default = baseDirDefaultVal;
      description =
        "The absolute path where the service will store the important informations";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.nextcloud = { uid = 985; };
    users.groups.nextcloud = { gid = 983; };

    sops.secrets = {
      "n100/nextcloud/oidc-client-secret" = { };
      "n100/nextcloud/admin-password" = { owner = "nextcloud"; };
    };

    # https://mynixos.com/nixpkgs/option/services.nextcloud.secretFile
    # Json formatted config.php
    sops.templates."n100/nextcloud/config-secrets" = {
      content = ''
        {
          "oidc_login_client_secret": "${
            config.sops.placeholder."n100/nextcloud/oidc-client-secret"
          }"
        }
      '';
      owner = "nextcloud";
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
      home = cfg.baseDir;
      settings = {
        trusted_proxies = [ "127.0.0.1" ];
        "allow_user_to_change_display_name" = false;
        "lost_password_link" = "disabled";
        "oidc_login_provider_url" =
          "https://${hcfg.authelia.domain}.${hcfg.domain}";
        "oidc_login_client_id" = "nextcloud";
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
      secretFile = config.sops.templates."n100/nextcloud/config-secrets".path;
      extraApps = {
        # the name here should be the same as the name of pacakge otherwise "App not found error"
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
      host = cfg.domain;
      port = 11112;
    }];

    homelab.authelia.bypassDomains = [ dname ];

    ######################################
    # Set up the dumping of the database #
    # Duplicated in Nextcloud            #
    ######################################
    systemd.tmpfiles.rules = [ "d /var/lib/pgdump 0755 postgres postgres -" ];

    # Create a service to backup the PG database
    systemd.services.pgDumpNextcloud = {
      description = "PostgreSQL dump of the nextcloud database";
      after = [ "postgresql.service" ];

      serviceConfig = {
        Type = "oneshot";
        User = "postgres";
        ExecStart =
          "${pkgs.postgresql}/bin/pg_dump -f /var/lib/pgdump/${dbname}_dump.sql ${dbname}";
      };
    };

    # generate wrapper scripts, as described in the createWrapper option
    environment.systemPackages = [
      (pkgs.writeShellScriptBin "restore-nextcloud-pg" ''
        systemctl stop ${servicename}
        sudo -u postgres ${pkgs.postgresql}/bin/dropdb --if-exists ${dbname}
        sudo -u postgres ${pkgs.postgresql}/bin/createdb ${dbname}
        sudo -u postgres ${pkgs.postgresql}/bin/psql -d ${dbname} -f /var/lib/pgdump/${dbname}_dump.sql
        systemctl start ${servicename}
      '')
    ];
    ######################################
    # End of duplication                 #
    ######################################

    homelab.backup = {
      stateDirs = [ cfg.baseDir "/var/lib/pgdump" ];
      preBackupScripts = [ "systemctl start pgDumpNextcloud" ];
    };

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
        "$pbkdf2-sha512$310000$YbTheSu9VfRbSXkg3v39WA$CwBcFJy3hZlF94it/r5aPGIP1r4RXfxu9ZgpUpPH0dBOAlcih8RhSGCeVWHXoOzQR5Jyx3Vp9Whu.uywamjV9Q";
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
