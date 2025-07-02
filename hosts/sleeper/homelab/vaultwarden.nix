{ config, lib, ... }:
let
  cfg = config.homelab.vaultwarden;
  domain = "${cfg.domain}.${config.homelab.domain}";
in {
  options.homelab.vaultwarden = {
    enable = lib.mkEnableOption "vaultwarden";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "bitwarden";
      description = "The subdomain where the service will be served";
    };

    baseBackupDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/backup-valutwarden";
      description = "The absolute path where the service will store the important informations";
    };
  };

  config = lib.mkIf cfg.enable {
    # Define user ids
    users.users.vaultwarden.uid = 993;
    users.groups.vaultwarden.gid = 991;

    services.vaultwarden = {
      enable = true;
      config = {
        DOMAIN = "https://${domain}";
        SIGNUPS_ALLOWED = false;
        ROCKET_ADDRESS = "127.0.0.1";
        ROCKET_PORT = 11110;
      };
      backupDir = cfg.baseBackupDir;
    };

    homelab.traefik.routes = [{
      host = cfg.domain;
      port = 11110;
    }];

    homelab.authelia.bypassDomains = [ domain ];

    # Back up not only the backup location but the original dir too (should work out of the box)
    homelab.backup.stateDirs = [ cfg.baseBackupDir "/var/lib/vaultwarden" ];

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
