{ config, lib, ... }:
let cfg = config.homelab.ollama;  
  subdomain = "ollama";
in {
  options.homelab.ollama = {
    enable = lib.mkEnableOption "Ollama";
    loadModels = config.services.ollama.loadModels.acceleration;
    acceleration = config.services.ollama.options.acceleration;
  };

  config = lib.mkIf cfg.enable {
    services.ollama = {
      enable = true;
      acceleration = cfg.acceleration;
      host = "127.0.0.1";
      port = 11434;
      loadModels = cfg.loadModels;
    };

    homelab.traefik.routes = [{
      host = subdomain;
      port = 11434;
    }];

    homelab.homepage.service = [{
      Ollama = {
        icon = "ollama.png";
        href = "https://${subdomain}.${config.homelab.domain}";
        siteMonitor = "https://${subdomain}.${config.homelab.domain}";
        description = "LLM at home";
      };
    }];
  };
}
