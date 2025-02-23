{ config, lib, ... }:
let cfg = config.homelab;
in {
  imports = [
    ./vaultwarden.nix
    ./adguard.nix
    ./ddclient.nix
  ];

  options.homelab = {
    # This needs custom functionality for nested module definitions
    # see https://discourse.nixos.org/t/correct-way-to-disable-submodules-with-top-module-enable-option/47199/4
    enable = lib.mkEnableOption "homelab";
    domain = lib.mkOption {
      type = lib.types.str;
      default = "berky.me";
    };
    serverIP = lib.mkOption {
      type = lib.types.str;
      default = "192.168.1.127";
    };
    gateway = lib.mkOption {
      type = lib.types.str;
      default = "192.168.1.1";
    };
  };

  config = lib.mkIf cfg.enable {
    # Get static ip address instead of dhcp
    networking = {
      useDHCP = false; # Disable DHCP to allow static IP configuration

      interfaces = {
        ens18 = {
          ipv4.addresses = [{
            address = cfg.serverIP; # Your desired static IP address
            prefixLength = 32; # Subnet mask in CIDR notation
          }];
        };
      };

      defaultGateway = cfg.gateway;
      # DNS settings
      nameservers =
        [ "1.1.1.1" "8.8.8.8" ]; # Replace with your preferred DNS servers
    };

    # Enable binding on the 80 and 443 port for docker
    boot.kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = 0;

    # Open ports for reverse proxy
    networking.firewall.allowedTCPPorts = [ 80 443 ];
    # Open ports for DNS server
    networking.firewall.allowedUDPPorts = [ 53 ];
  };
}
