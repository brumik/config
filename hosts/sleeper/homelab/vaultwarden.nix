{ config, lib, ... }:
let
  hcfg = config.homelab;
  cfg = hcfg.vaultwarden;
  domain = "${cfg.domain}.${config.homelab.domain}";
  vaultwarden = config.globals.users.vaultwarden;
in {
  options.homelab.vaultwarden = {
    enable = lib.mkEnableOption "vaultwarden";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "bitwarden";
      description = "The subdomain where the service will be served";
    };

    backupDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/backup-valutwarden";
      description = "The absolute path where the service will store the important informations";
    };
  };

  config = lib.mkIf (hcfg.enable && cfg.enable) {
    # Define user ids
    users.users."${vaultwarden.uname}".uid = vaultwarden.uid;
    users.groups."${vaultwarden.gname}".gid = vaultwarden.gid;

    services.vaultwarden = {
      enable = true;
      config = {
        DOMAIN = "https://${domain}";
        SIGNUPS_ALLOWED = false;
        ROCKET_ADDRESS = "127.0.0.1";
        ROCKET_PORT = 11110;
      };
      backupDir = cfg.backupDir;
    };

    homelab.traefik.routes = [{
      host = cfg.domain;
      port = 11110;
    }];

    homelab.authelia.bypassDomains = [ domain ];

    homelab.homepage.app = [{
      Bitwarden = {
        icon = "bitwarden.png";
        href = "https://${domain}";
        siteMonitor = "https://${domain}";
        description = "Password manager";
      };
    }];
  };
}
