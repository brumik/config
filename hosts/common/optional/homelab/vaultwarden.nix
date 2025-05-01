{ config, lib, ... }:
let
  cfg = config.homelab.vaultwarden;
  domain = "bitwarden.${config.homelab.domain}";
  dir = "/var/lib/backup-valutwarden";
in {
  options.homelab.vaultwarden = {
    enable = lib.mkEnableOption "vaultwarden";
    port = lib.mkOption {
      default = 10001;
      type = lib.types.port;
    };
    address = lib.mkOption {
      default = "127.0.0.1";
      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    services.vaultwarden = {
      enable = true;
      config = {
        DOMAIN = "https://${domain}";
        SIGNUPS_ALLOWED = false;
        ROCKET_ADDRESS = "${cfg.address}";
        ROCKET_PORT = cfg.port;
      };
      backupDir = dir;
    };

    homelab.traefik.routes = [{
      host = "bitwarden";
      port = cfg.port;
    }];

    homelab.authelia.bypassDomains = [ domain ];

    # Back up not only the backup location but the original dir too (should work out of the box)
    homelab.backup.stateDirs = [ dir "/var/lib/vaultwarden" ];

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
