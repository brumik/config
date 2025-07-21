{ config, lib, ... }:
let
  cfg = config.homelab.n8n;
  cfgh = config.homelab;
  dname = "${cfg.domain}.${cfgh.domain}";
  # baseDirDefaultVal = "/var/lib/n8n";
in {
  options.homelab.n8n = {
    enable = lib.mkEnableOption "n8n";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "n8n";
      description = "The subdomain where the service will be served";
    };

    # baseDir = lib.mkOption {
    #   type = lib.types.path;
    #   default = "/var/lib/n8n";
    #   description = "The absolute path where the service will store the important informations";
    # };
  };

  config = lib.mkIf cfg.enable {
    services.n8n = {
      enable = true;
      settings = {
        N8N_HOST = dname; # Host name n8n runs on.
        N8N_PORT = "5678"; # The HTTP port n8n runs on.
        N8N_LISTEN_ADDRESS = "::";
      };
    };

    homelab.traefik.routes = [{
      host = cfg.domain;
      port = 5678;
    }];
  };
}
