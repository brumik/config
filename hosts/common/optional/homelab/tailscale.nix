{ config, lib, ... }:
let cfg = config.homelab.tailscale;
in {
  options.homelab.tailscale = { enable = lib.mkEnableOption "tailscale"; };

  config = lib.mkIf cfg.enable {
    sops.secrets."n100/tailscale-key" = {};
    services.tailscale = {
      enable = true;
      openFirewall = true;
      useRoutingFeatures = "server";
      authKeyFile = config.sops.secrets."n100/tailscale-key".path;
      # extraUpFlags = [
      #   # These are for servers only. If you want to use it for personal PC remove
      #   "--accept-routes"
      #   "--advertise-exit-node"
      #   "--ssh"
      #   "--reset"
      # ];
    };
  };
}
