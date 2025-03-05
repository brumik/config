{ config, lib, ... }:
let cfg = config.homelab.radicale;
in {
  options.homelab.radicale = {
    enable = lib.mkEnableOption "radicale";

    usersFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to the bcryped users file";
    };
  };

  config = lib.mkIf cfg.enable {
    sops.secrets."n100/radicale-users" = { owner = "radicale"; };

    services.radicale = {
      enable = true;
      settings = {
        server = { hosts = [ "127.0.0.1:5232" ]; };
        auth = {
          type = "htpasswd";
          htpasswd_filename = config.sops.secrets."n100/radicale-users".path;
          htpasswd_encryption = "bcrypt";
        };
        storage = { filesystem_folder = "/var/lib/radicale/collections"; };
      };
    };

    services.traefik = config.homelab.traefik.createRouter {
      name = "radicale";
      port = 5232;
    };

    homelab.authelia.bypassDomains = [ "radicale.${config.homelab.domain}" ];

    homelab.backup.stateDirs = [ "/var/lib/radicale/collections" ];

    networking.firewall.allowedTCPPorts = [ 5232 ];
  };
}
