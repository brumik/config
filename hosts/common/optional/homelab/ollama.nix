{ config, lib, ... }:
let
  cfg = config.homelab.ollama;
  hcfg = config.homelab;
  acceleration = if hcfg.gpu == "nvidia" then
    "cuda"
  else if hcfg.gpu == "amd" then
    "rocm"
  else
    null;
in {
  options.homelab.ollama = {
    enable = lib.mkEnableOption "Ollama";

    loadModels = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "gemma3:12b" ];
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
    assertions = [{
      assertion = hcfg.gpu != null;
      message =
        "You must specify a GPU vendor (nvidia or amd) when using Ollama";
    }];

    services.ollama = {
      enable = true;
      acceleration = acceleration;
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
