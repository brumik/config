{ config, lib, ... }:
let cfg = config.homelab.tailscale;
in {
  options.homelab.tailscale = {
    enable = lib.mkEnableOption "tailscale";

    serverIP = lib.mkOption {
      type = lib.types.str;
      example = "100.0.10.10";
      description = "The IP in tailscale network";
    };

    subnet = lib.mkOption {
      type = lib.types.str;
      default = "100.0.0.0/8";
      description = "The whole subnet that classifies as tailscale network";
    };

    trustedIPs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = ''
        The list of IPs that are allowed to access services as if it would be localhost
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    sops.secrets."n100/tailscale-key" = {};
    services.tailscale = {
      enable = true;
      useRoutingFeatures = "server"; # should include advertise-exit-node and others
      authKeyFile = config.sops.secrets."n100/tailscale-key".path;
    };
  };
}
