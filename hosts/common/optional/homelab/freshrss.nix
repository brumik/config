{ config, lib, ... }:
let
  cfg = config.homelab.freshrss;
  dname = "${cfg.domain}.${config.homelab.domain}";
in {
  options.homelab.freshrss = {
    enable = lib.mkEnableOption "freshrss";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "rss";
      description = "The subdomain where the service will be served";
    };

    baseDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/oci-freshrss";
      description = "The absolute path where the service will store the important informations";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d ${cfg.baseDir} 0755 - - -"
      "d ${cfg.baseDir}/extensions 0755 - - -"
      "d ${cfg.baseDir}/data 0755 - - -"
    ];

    sops.secrets."n100/freshrss-credentials" = { };

    virtualisation.oci-containers.containers.freshrss = {
      image = "freshrss/freshrss";
      ports = [ "10003:80" ];
      volumes = [
        "${cfg.baseDir}/data:/var/www/FreshRSS/data"
        "${cfg.baseDir}/extensions:/var/www/FreshRSS/extensions"
      ];
      environment = {
        # A timezone http://php.net/timezones (default is UTC)
        TZ = "${config.time.timeZone}";
        # Cron job to refresh feeds at specified minutes
        CRON_MIN = "2,32";
        # 'development' for additional logs; default is 'production'
        # FRESHRSS_ENV: development
        # Optional advanced parameter controlling the internal Apache listening port
        LISTEN = "0.0.0.0:80";
        # Optional parameter, remove for automatic settings, set to 0 to disable,
        # or (if you use a proxy) to a space-separated list of trusted IP ranges
        # compatible with https://httpd.apache.org/docs/current/mod/mod_remoteip.html#remoteipinternalproxy
        # This impacts which IP address is logged (X-Forwarded-For or REMOTE_ADDR).
        # This also impacts external authentication methods;
        # see https://freshrss.github.io/FreshRSS/en/admins/09_AccessControl.html
        TRUSTED_PROXY = "172.16.0.1/12 192.168.0.1/16 10.0.0.0/8";
        # Optional parameter, set to 1 to enable OpenID Connect (only available in our Debian image)
        # Requires more environment variables. See https://freshrss.github.io/FreshRSS/en/admins/16_OpenID-Connect.html
        OIDC_ENABLED = "1";
        OIDC_PROVIDER_METADATA_URL =
          "https://${config.homelab.authelia.domain}.${config.homelab.domain}/.well-known/openid-configuration";
        OIDC_CLIENT_ID = "freshrss";
        OIDC_REMOTE_USER_CLAIM = "preferred_username";
        OIDC_SCOPES = "openid groups email profile";
        OIDC_X_FORWARDED_HEADERS =
          "X-Forwarded-Host X-Forwarded-Port X-Forwarded-Proto";
      };
      environmentFiles =
        [ config.sops.secrets."n100/freshrss-credentials".path ];
    };

    homelab.traefik.routes = [{
      host = cfg.domain;
      port = 10003;
    }];

    homelab.authelia.oidc.clients = [{
      client_id = "freshrss";
      client_name = "FreshRSS";
      client_secret =
        "$pbkdf2-sha512$310000$yw9HeEPelo9ebAkzDJBWkA$diTSif9RC5TPkzl.mCCHqpvquOkwOYj5GV8u/fyVvYLe2DAueVVgz0pa8lsKmHEAN2FwlEvQgzlzLGftz9ze4A";
      public = false;
      consent_mode = "implicit";
      authorization_policy = "one_factor";
      redirect_uris = [ "https://${dname}:443/i/oidc/" ];
      scopes = [ "openid" "email" "profile" "groups" ];
      userinfo_signed_response_alg = "none";
      token_endpoint_auth_method = "client_secret_basic";
    }];

    homelab.authelia.exposedDomains = [ dname ];

    homelab.backup.stateDirs = [ cfg.baseDir ];

    homelab.homepage.app = [{
      FreshRSS = {
        icon = "freshrss.png";
        href = "https://${dname}";
        siteMonitor = "https://${dname}";
        description = "Rss feed manager";
      };
    }];
  };
}
