{ config, lib, ... }:
let
  cfg = config.homelab.gitea;
  hcfg = config.homelab;
  dname = "${cfg.domain}.${hcfg.domain}";
  gitea = config.globals.users.gitea;
in
{
  options.homelab.gitea = {
    enable = lib.mkEnableOption "Gitea";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "git";
      description = "The subdomain where the service will be served";
    };

    baseDir = lib.mkOption {
      type = lib.types.path;
      default = "/persist/gitea";
      description = "The absolute path where Gitea will store the important information";
    };
  };

  config = lib.mkIf (hcfg.enable && cfg.enable) {
    # Define Gitea user and group
    users.groups.${gitea.gname}.gid = gitea.gid;
    users.users.${gitea.uname} = {
      uid = gitea.uid;
    };

    # Create persistent directory for Gitea
    systemd.tmpfiles.rules = [
      "d '${cfg.baseDir}' 700 ${gitea.uname} ${gitea.gname} -"
    ];

    # Configure Gitea service with persistent storage
    services.gitea = {
      enable = true;
      user = gitea.uname;
      group = gitea.gname;
      stateDir = cfg.baseDir;

      settings = {
        server = {
          HTTP_ADDR = "127.0.0.1";
          HTTP_PORT = 10012;
          ROOT_URL = "https://${dname}";
        };
        service = {
          DISABLE_REGISTRATION = false; # disable after initial admin user creation
          # OIDC only
          ALLOW_ONLY_EXTERNAL_REGISTRATION = true;
          SHOW_REGISTRATION_BUTTON = false;
          # Didn't wanted to work
          # ENABLE_REVERSE_PROXY_AUTHENTICATION = true;
          # ENABLE_REVERSE_PROXY_AUTO_REGISTRATION = true;
          # REVERSE_PROXY_AUTHENTICATION_USER = "Remote-User";
          # REVERSE_PROXY_AUTHENTICATION_EMAIL = "Remote-Email";
          # ENABLE_REVERSE_PROXY_FULL_NAME = true;
          # REVERSE_PROXY_AUTHENTICATION_FULL_NAME = "Remote-Name";
        };
        openid = {
          ENABLE_OPENID_SIGNIN = false;
          ENABLE_OPENID_SIGNUP = true;
        };
        oauth2_client = {
          OPENID_CONNECT_SCOPES = "email profile";
          UPDATE_AVATAR = true;
          USERNAME = "user_id";
          ACCOUNT_LINKING = "auto";
          WHITELISTED_URIS = dname;
        };
        mailer = {
          ENABLED = true;
          PROTOCOL = "sendmail";
          FROM = "Gitea <gitea@berky.me>";
        };
      };

      database = {
        type = "sqlite3";
      };
    };

    # Register with Traefik
    homelab.traefik.routes = [
      {
        host = cfg.domain;
        port = config.services.gitea.settings.server.HTTP_PORT;
      }
    ];

    # Add to backup state dirs
    homelab.backup.stateDirs = [ cfg.baseDir ];

    homelab.authelia.oidc.clients = [
      {
        client_id = "gitea";
        client_name = "Gitea";
        client_secret = "$pbkdf2-sha512$310000$5.VQ0cFgoKschfpQRPr1sQ$EkgjOz0HM0PMeFusHmoqtfx8yupBZIBBesbdM09w590MGzlc37/xL1dkxXkgzac8YG4p65AY8OSs217UY8CYQA";
        public = false;
        consent_mode = "implicit";
        authorization_policy = "one_factor";
        require_pkce = false;
        pkce_challenge_method = "";
        redirect_uris = [
          "https://${dname}/user/oauth2/authelia/callback"
        ];
        scopes = [
          "openid"
          "email"
          "profile"
        ];
        response_types = [ "code" ];
        grant_types = [ "authorization_code" ];
        access_token_signed_response_alg = "none";
        userinfo_signed_response_alg = "none";
        token_endpoint_auth_method = "client_secret_basic";
      }
    ];

    # Homepage entry
    homelab.homepage.app = [
      {
        Gitea = {
          icon = "gitea.png";
          href = "https://${dname}";
          siteMonitor = "https://${dname}/api/v1/version";
          description = "Self-hosted Git service";
        };
      }
    ];
  };
}
