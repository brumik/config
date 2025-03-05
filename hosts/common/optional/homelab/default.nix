{ config, lib, ... }:
let cfg = config.homelab;
in {
  imports = [
    ./smbClient.nix
    ./vaultwarden.nix
    ./adguard.nix
    ./ddclient.nix
    ./jellyfin.nix
    ./lldap.nix
    ./backup.nix
    ./radicale.nix
    ./languagetool.nix
    ./mealie.nix
    ./freshrss.nix
    # ./homepage.nix
    ./traefik
    ./authelia
    ./tailscale.nix
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

    user = lib.mkOption {
      default = "share";
      type = lib.types.str;
      description = ''
        User to run the homelab services as
      '';
    };
    group = lib.mkOption {
      default = "share";
      type = lib.types.str;
      description = ''
        Group to run the homelab services as
      '';
    };

    smbServerIP = lib.mkOption {
      type = lib.types.str;
      default = "192.168.1.2";
    };
  };

  config = lib.mkIf cfg.enable {
    users = {
      groups.${cfg.group} = { gid = 993; };
      users.${cfg.user} = {
        uid = 994;
        isSystemUser = true;
        group = cfg.group;
      };
    };

    # Get static ip address instead of dhcp
    networking = {
      # TODO: if enabled networkmanager it conflicts, if not it is not getting internet
      # useDHCP = true; # Disable DHCP to allow static IP configuration

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

    # Enable podman and set all container based services to it;
    virtualisation.podman.enable = true;
    virtualisation.oci-containers.backend = "podman";

    # Open ports for reverse proxy
    networking.firewall.allowedTCPPorts = [ 80 443 ];
    # Open ports for DNS server
    networking.firewall.allowedUDPPorts = [ 53 ];
  };
}
