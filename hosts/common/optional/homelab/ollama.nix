{ config, lib, ... }:
let cfg = config.homelab.ollama;
in {
  options.homelab.ollama = {
    enable = lib.mkEnableOption "Ollama";
    loadModels = config.services.ollama.loadModels.acceleration;
    acceleration = config.services.ollama.options.acceleration;

    domain = lib.mkOption {
      type = lib.types.str;
      default = "ollama";
      description = "The subdomain where the service will be served";
    };
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
      host = cfg.domain;
      port = 11434;
    }];

    homelab.homepage.services = [{
      Ollama = {
        icon = "ollama.png";
        href = "https://${cfg.domain}.${config.homelab.domain}";
        siteMonitor = "https://${cfg.domain}.${config.homelab.domain}";
        escription = "LLM at home";
      };
    }];
  };
}
