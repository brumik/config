{ config, lib, ... }:
let cfg = config.homelab.languagetool;
in {
  options.homelab.languagetool = {
    enable = lib.mkEnableOption "languagetool";
  };

  config = lib.mkIf cfg.enable {
    services.languagetool = {
      enable = true;
      # jvmOptions = [ "-Xmx512m" ];
    };

    homelab.traefik.routes = [{
      host = "languagetool";
      port = 8081;
    }];
  };
}
