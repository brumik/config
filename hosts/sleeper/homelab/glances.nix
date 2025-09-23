{ config, lib, ... }:
let
  cfg = config.homelab.glances;
  hcfg = config.homelab;
  dname = "${cfg.domain}.${hcfg.domain}";
in {
  options.homelab.glances = {
    enable = lib.mkEnableOption "Glances";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "glances";
      description = "The subdomain where the service will be served";
    };
  };

  config = lib.mkIf cfg.enable {
    services.glances = {
      enable = true;
      # port 61208
    };

    homelab.traefik.routes = [{
      host = cfg.domain;
      port = 61208;
    }];

    homelab.authelia.localBypassDomains = [ dname ];

    homelab.homepage.admin = [{
      Glances = {
        icon = "glances.png";
        href = "https://${dname}";
        siteMonitor = "https://${dname}";
        description = "System resource monitoring.";
      };
    }];
  };
}
