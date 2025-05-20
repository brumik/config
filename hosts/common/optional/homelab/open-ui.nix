{ config, lib, ... }:
let
  cfg = config.homelab.open-webui;
in {
  options.homelab.open-webui = {
    enable = lib.mkEnableOption "open-webui";
    
    domain = lib.mkOption {
      type = lib.types.str;
      default = "chat";
      description = "The subdomain where the service will be served";
    };

    baseDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/open-webui";
      description = "The absolute path where the service will store the important informations";
    };
  };

  config = lib.mkIf cfg.enable {
    # Requires ollama running
    homelab.ollama.enable = true;

    services.open-webui = {
      enable = true;
      host = "127.0.0.1";
      port = 11111;
      stateDir = cfg.baseDir;
      environment = {
        OLLAMA_API_BASE_URL = "http://127.0.0.1:${builtins.toString config.services.ollama.port}";
        # Disable authentication
        WEBUI_AUTH = "False";
      };
    };

    homelab.traefik.routes = [{
      host = cfg.domain;
      port = 11111;
    }];

    homelab.authelia.exposedDomains =
      [ "${cfg.domain}.${config.homelab.domain}" ];

    homelab.homepage.app = [{
      OpenWebUI = {
        icon = "open-webui.png";
        href = "https://${cfg.domain}.${config.homelab.domain}";
        siteMonitor = "https://${cfg.domain}.${config.homelab.domain}";
        description = "ChatGPT at home";
      };
    }];
  };
}
