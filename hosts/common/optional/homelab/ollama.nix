{ config, lib, ... }:
let
  cfg = config.homelab.ollama;
  hcfg = config.homelab;
in {
  options.homelab.ollama = {
    enable = lib.mkEnableOption "Ollama";

    loadModels = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description =
        "The list of models that will be avaiable after system build";
    };

    domain = lib.mkOption {
      type = lib.types.str;
      default = "ollama";
      description = "The subdomain where the service will be served";
    };
  };

  config = lib.mkIf cfg.enable {
    services.ollama = {
      enable = true;
      host = "0.0.0.0";
      port = 11434;
      environmentVariables = {
        OLLAMA_ORIGINS = "*";
        OLLAMA_FLASH_ATTENTION = "1";
      };
      loadModels = cfg.loadModels;
    };

    homelab.traefik.routes = [{
      host = cfg.domain;
      port = 11434;
    }];

    homelab.homepage.services = [{
      Ollama = {
        icon = "ollama.png";
        href = "https://${cfg.domain}.${hcfg.domain}";
        siteMonitor = "https://${cfg.domain}.${hcfg.domain}";
        escription = "LLM at home";
      };
    }];
  };
}
