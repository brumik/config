{ config, lib, ... }:
let cfg = config.homelab.tailscale;
in {
  options.homelab.tailscale = { enable = lib.mkEnableOption "tailscale"; };

  config = lib.mkIf cfg.enable {
    sops.secrets."n100/tailscale-key" = {};
    services.tailscale = {
      enable = true;
      useRoutingFeatures = "server"; # should include advertise-exit-node and others
      extraUpFlags = [ "--ssh" ];
      authKeyFile = config.sops.secrets."n100/tailscale-key".path;
    };
  };
}
