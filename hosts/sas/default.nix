{ config, ... }:
let sleeperTailscaleIp = "100.93.65.122";
in {
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

  # Enable IPv4 forwarding
  boot.kernel.sysctl."net.ipv4.ip_forward" = true;

  networking.nat = {
    enable = true;

    # External interface (VPS public NIC)
    externalInterface = "eth0";

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
    ];
  };

  # Allow forwarding in firewall
  networking.firewall = {
    enable = true;

    # Allow incoming HTTP/HTTPS on eth0
    allowedTCPPorts = [ 80 443 ];

    # Explicit forwarding rules
    extraCommands = ''
      iptables -A FORWARD -i eth0 -o tailscale0 -p tcp -m multiport --dports 80,443 -j ACCEPT
      iptables -A FORWARD -i tailscale0 -o eth0 -m state --state ESTABLISHED,RELATED -j ACCEPT
      iptables -t nat -A POSTROUTING -o tailscale0 -j MASQUERADE
    '';
  };

  services.minecraft-server = {
    enable = true;
    openFirewall = true;
    declarative = true;
    eula = true;
    serverProperties = {
      server-port = 43000;
      max-players = 5;
      motd = "NixOS Minecraft server!";
      white-list = true;
      enable-rcon = false; # monitoring tool
      # "rcon.password" = "hunter2";
    };
    whitelist = {
      username1 = "332f4e53-0ceb-4655-89c8-fe6195d4afb9";
      # username2 = "yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy";
    };
  };
}
