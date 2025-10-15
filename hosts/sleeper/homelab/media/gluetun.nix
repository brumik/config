{ config, lib, ... }:
let
  cfg = config.homelab.media.gluetun;
  hcfg = config.homelab;
in {
  options.homelab.media.gluetun = {
    enable = lib.mkEnableOption "gluetun";
  };

  config = lib.mkIf (hcfg.enable && hcfg.media.enable && cfg.enable) {
    sops.secrets."n100/protonvpn-wireguard-private-key" = { };
    sops.templates."n100/gluetun/.env" = {
      content = ''
        WIREGUARD_PRIVATE_KEY=${
          config.sops.placeholder."n100/protonvpn-wireguard-private-key"
        }
      '';
    };

    virtualisation.oci-containers.containers = {
      gluetun = {
        image = "qmcgaw/gluetun";
        pull = "always";
        capabilities = { NET_ADMIN = true; };
        environment = {
          VPN_SERVICE_PROVIDER = "protonvpn";
          VPN_TYPE = "wireguard";
          SERVER_COUNTRIES = "Germany";
          VPN_PORT_FORWARDING = "on";
        };
        environmentFiles = [ config.sops.templates."n100/gluetun/.env".path ];
        devices = [ "/dev/net/tun:/dev/net/tun" ];
      };
    };
  };
}
