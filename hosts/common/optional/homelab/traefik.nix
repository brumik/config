{ config, lib, ... }:
let cfg = config.homelab.traefik;
in {
  options.homelab.traefik = {
    enable = lib.mkEnableOption "traefik";
  };

  config = lib.mkIf cfg.enable {
    services.traefik = {
      enable = true;
    };


    homelab.backup.stateDirs = [ "/var/lib/traefik" ];
  };
}
