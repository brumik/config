{ config, lib, ... }:
let
  cfg = config.homelab.stirling-pdf;
  hcfg = config.homelab;
  dname = "${cfg.domain}.${hcfg.domain}";
  baseDirDefaultVal = "/var/lib/stirling-pdf";
in {
  options.homelab.stirling-pdf = {
    enable = lib.mkEnableOption "stirling-pdf";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "pdf";
      description = "The subdomain where the service will be served";
    };

    baseDir = lib.mkOption {
      type = lib.types.path;
      default = baseDirDefaultVal;
      description =
        "The absolute path where the service will store the important informations";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = lib.mkIf (cfg.baseDir != baseDirDefaultVal) [
      "d ${cfg.baseDir} 0755 root root -"
      "L ${baseDirDefaultVal} - - - - ${cfg.baseDir}"
    ];

    services.stirling-pdf = {
      enable = true;
      environment = {
        SERVER_PORT = 11120;
        SERVER_ADDRESS = "127.0.0.1";
      };
    };

    homelab.traefik.routes = [{
      host = cfg.domain;
      port = 11120;
    }];

    homelab.backup.stateDirs = [ cfg.baseDir ];
    
    homelab.authelia.exposedDomains = [ dname ];

    homelab.homepage.app = [{
      StirlingPDF = {
        icon = "stirling-pdf.png";
        href = "https://${dname}";
        siteMonitor = "https://${dname}";
        description = "Edit PDF like never before.";
      };
    }];
  };
}
