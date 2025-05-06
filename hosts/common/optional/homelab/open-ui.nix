{ config, lib, ... }:
let
  cfg = config.homelab.open-webui;
  subdomain = "chat";
in {
  options.homelab.open-webui = { enable = lib.mkEnableOption "open-webui"; };

  config = lib.mkIf cfg.enable {
    services.open-webui = {
      enable = true;
      host = "0.0.0.0";
      port = 11111;
      environment = {
        OLLAMA_API_BASE_URL = "http://127.0.0.1:11434";
        # Disable authentication
        WEBUI_AUTH = "False";
      };
    };

    homelab.traefik.routes = [{
      host = subdomain;
      port = 11434;
    }];

    homelab.authelia.exposedDomains =
      [ "${subdomain}.${config.homelab.domain}" ];

    homelab.homepage.app = [{
      OpenWebUI = {
        icon = "open-webui.png";
        href = "https://${subdomain}.${config.homelab.domain}";
        siteMonitor = "https://${subdomain}.${config.homelab.domain}";
        description = "ChatGPT at home";
      };
    }];
  };
}
