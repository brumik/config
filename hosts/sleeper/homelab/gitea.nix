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
      group = gitea.group;
      stateDir = cfg.baseDir;

      settings = {
        server = {
          HTTP_ADDR = "127.0.0.1";
          HTTP_PORT = 10012;
          ROOT_URL = dname;
        };
        service = {
          DISABLE_REGISTRATION = false; # disable after initial admin user creation
          ENABLE_REVERSE_PROXY_AUTHENTICATION = true;
          ENABLE_REVERSE_PROXY_AUTO_REGISTRATION = true;
          REVERSE_PROXY_AUTHENTICATION_USER = "Remote-User";
          REVERSE_PROXY_AUTHENTICATION_EMAIL = "Remote-Email";
          ENABLE_REVERSE_PROXY_FULL_NAME = true;
          REVERSE_PROXY_AUTHENTICATION_FULL_NAME = "Remote-Name";
        };
      };

      database = {
        type = "sqlite3";
      };

      mailbox = {
        ENABLED = true;
        PROTOCOL = "sendmail";
        FROM = "Gitea <gitea@berky.me>";
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

    # Homepage entry
    homelab.homepage.app = [
      {
        Gitea = {
          href = "https://${dname}";
          siteMonitor = "https://${dname}/api/v1/version";
          description = "Self-hosted Git service with OIDC authentication";
        };
      }
    ];
  };
}
