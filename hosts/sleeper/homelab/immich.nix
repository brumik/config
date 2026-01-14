{ config, lib, pkgs, ... }:
let
  cfg = config.homelab.immich;
  dname = "${cfg.domain}.${config.homelab.domain}";
  immich = config.globals.users.immich;
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
      description =
        "The absolute path where the service will store the important informations";
    };
  };

  config = lib.mkIf cfg.enable {
    users = {
      groups.${immich.gname} = { gid = immich.gid; };
      users.${immich.uname} = { 
        uid = immich.uid;

        # Needed for gpu accelerated machine learning
        extraGroups = [ "video" "render" ];
      };
    };

    services.immich = {
      enable = true;
      mediaLocation = cfg.baseDir;
      host = "127.0.0.1";
      port = 2283;
      user = immich.uname;
      group = immich.gname;
      environment = {
        IMMICH_TRUSTED_PROXIES = "127.0.0.1";
        IMMICH_TELEMETRY_INCLUDE = "all";
        IMMICH_API_METRICS_PORT = "8084";
        IMMICH_MICROSERVICES_METRICS_PORT = "8085";
      };
      accelerationDevices =
        [ "/dev/nvidia0" "/dev/nvidiactl" "/dev/nvidia-uvm" ];
      # I migrated to vector chord but my stateVersion is <25.11 so I need to manually disable this
      database.enableVectors = false;
    };

    homelab.traefik.routes = [{
      host = cfg.domain;
      port = config.services.immich.port;
    }];

    homelab.authelia.bypassDomains = [ dname ];

    ######################################
    # Set up the dumping of the database #
    # Duplicated in Nextcloud            #
    ######################################
    systemd.tmpfiles.rules = [ "d /var/lib/pgdump 0755 postgres postgres -" ];

    # Create a service to backup the PG database
    systemd.services.pgDumpImmich = {
      description = "PostgreSQL dump of the immich database";
      after = [ "postgresql.service" ];

      serviceConfig = {
        Type = "oneshot";
        User = "postgres";
        ExecStart =
          "${pkgs.postgresql}/bin/pg_dump -f /var/lib/pgdump/immich_dump.sql immich";
      };
    };

    # generate wrapper scripts, as described in the createWrapper option
    environment.systemPackages = [
      (pkgs.writeShellScriptBin "restore-immich-pg" ''
        systemctl stop immich-server
        sudo -u postgres ${pkgs.postgresql}/bin/dropdb --if-exists immich
        sudo -u postgres ${pkgs.postgresql}/bin/createdb immich
        sudo -u postgres ${pkgs.postgresql}/bin/psql -d immich -f /var/lib/pgdump/immich_dump.sql
        systemctl start immich-server
      '')
    ];
    ######################################
    # End of duplication                 #
    ######################################

    homelab.backup = {
      stateDirs = [ cfg.baseDir "/var/lib/pgdump" ];
      preBackupScripts = [ "systemctl start pgDumpImmich" ];
    };

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
