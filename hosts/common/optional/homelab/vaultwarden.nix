{ config, lib, ... }:
let
  cfg = config.homelab.vaultwarden;
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
    openFirewall = lib.mkOption {
      default = false;
      type = lib.types.bool;
    };
  };

  config = lib.mkIf cfg.enable {
    services.vaultwarden = {
      enable = true;
      config = {
        DOMAIN = "https://bitwarden.${config.homelab.domain}";
        SIGNUPS_ALLOWED = false;
        ROCKET_ADDRESS = "${cfg.address}";
        ROCKET_PORT = cfg.port;
      };
    };

    services.traefik = config.homelab.traefik.createRouter {
      name = "bitwarden";
      port = cfg.port;
    };

    homelab.backup.stateDirs = [
      "/var/lib/vaultwarden/attachments"
      "/var/lib/vaultwarden/db.sqlite3"
    ];

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];
  };
}
