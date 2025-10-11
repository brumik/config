{ config, lib, ... }:
let
  cfg = config.homelab.radicale;
  radicale = config.globals.users.radicale;
in {
  options.homelab.radicale = {
    enable = lib.mkEnableOption "radicale";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "radicale";
      description = "The subdomain where the service will be served";
    };

    baseDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/radicale";
      description = "The absolute path where the service will store the important informations";
    };
  };

  config = lib.mkIf cfg.enable {
    # Define user ids
    users.users."${radicale.uname}".uid = radicale.uid;
    users.groups."${radicale.gname}".gid = radicale.gid;

    sops.secrets."n100/radicale-users" = { owner = radicale.uname; };

    services.radicale = {
      enable = true;
      settings = {
        server = { hosts = [ "127.0.0.1:5232" ]; };
        auth = {
          type = "htpasswd";
          htpasswd_filename = config.sops.secrets."n100/radicale-users".path;
          htpasswd_encryption = "bcrypt";
        };
        storage = { filesystem_folder = "${cfg.baseDir}/collections"; };
      };
    };

    homelab.traefik.routes = [{
      host = cfg.domain;
      port = 5232;
    }];

    homelab.authelia.bypassDomains = [ "${cfg.domain}.${config.homelab.domain}" ];

    homelab.backup.stateDirs = [ cfg.baseDir ];

    homelab.homepage.services = [{
      Radicale = {
        icon = "radicale.png";
        href = "https://${cfg.domain}.${config.homelab.domain}";
        siteMonitor = "https://${cfg.domain}.${config.homelab.domain}";
        description = "Calendar and contacts manager";
      };
    }];
  };
}
