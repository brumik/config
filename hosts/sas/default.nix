{ config, ... }:
let
  sleeperTailscaleIp = "100.93.65.122";
  externalInterface = "enp1s0";
  externalIPv6 = "2a01:4f8:c17:4b93::1";
in
{
  imports = [
    ./hardware-configuration.nix

    ../common/core
    ../common/optional/deployment-ssh.nix
  ];

  networking.hostName = "sas"; # Define your hostname.

  sops.secrets."n100/tailscale-key" = { };
  services.tailscale = {
    enable = true;
    extraUpFlags = [ "--advertise-exit-node" ];
    useRoutingFeatures = "server";
    authKeyFile = config.sops.secrets."n100/tailscale-key".path;
  };

  # Same as above with networking
  # networking.defaultGateway6 = {
  #   address = "fe80::1";
  #   interface = externalInterface;
  # };
  # networking.interfaces.${externalInterface}.ipv6.addresses = [
  #   {
  #     address = "${externalIPv6}";
  #     prefixLength = 64;
  #   }
  # ];

  # Enable IPv4 forwarding
  boot.kernel.sysctl."net.ipv4.ip_forward" = true;

  networking = {
    nat = {
      enable = true;

      # External interface (VPS public NIC)
      externalInterface = externalInterface;

      # Internal interface (Tailscale)
      internalInterfaces = [ "tailscale0" ];

      # Disable masqurade on eth0
      enableIPv6 = false;

      # Forward ports 80 and 443 to your home server
      forwardPorts = [
        {
          sourcePort = 80;
          proto = "tcp";
          destination = "${sleeperTailscaleIp}:80";
        }
        {
          sourcePort = 443;
          proto = "tcp";
          destination = "${sleeperTailscaleIp}:443";
        }
        # Minecraft server
        {
          sourcePort = 43000;
          proto = "tcp";
          destination = "${sleeperTailscaleIp}:43000";
        }
        {
          sourcePort = 43000;
          proto = "udp";
          destination = "${sleeperTailscaleIp}:43000";
        }
      ];
    };

    # Allow forwarding in firewall
    firewall = {
      enable = true;

      # Allow incoming HTTP/HTTPS on eth0
      # 43000 is for minecraft server foward
      allowedTCPPorts = [
        80
        443
        43000
      ];
      allowedUDPPorts = [ 43000 ];

      # Explicit forwarding rules
      extraCommands = ''
        iptables -A FORWARD -i ${externalInterface} -o tailscale0 -p tcp -m multiport --dports 80,443,43000 -j ACCEPT
        iptables -A FORWARD -i ${externalInterface} -o tailscale0 -p udp --dport 43000 -j ACCEPT
        iptables -A FORWARD -i tailscale0 -o ${externalInterface} -m state --state ESTABLISHED,RELATED -j ACCEPT
        iptables -t nat -A POSTROUTING -o tailscale0 -j MASQUERADE
      '';
    };
  };
}
