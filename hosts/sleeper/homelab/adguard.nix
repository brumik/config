{ config, lib, ... }:
let
  cfg = config.homelab.adguardhome;
  hcfg = config.homelab;
  dname = "${cfg.domain}.${hcfg.domain}";
  # This is retrieved from config itself
  # https://github.com/NixOS/nixpkgs/blob/d916df777523d75f7c5acca79946652f032f633e/nixos/modules/services/networking/adguardhome.nix#L203
  baseDir = "/var/lib/AdGuardHome";
in {
  options.homelab.adguardhome = {
    enable = lib.mkEnableOption "adguard";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "adguard";
      description = "The subdomain where the service will be served";
    };
  };

  # TODO: Disabled DHCP, when server restarted could not get and IP.
  # Since no IP for server no way to get DHCP for other devices.
  # Would neet static routing but it seems not working int TP link yet
  config = lib.mkIf cfg.enable {
    services.adguardhome = {
      enable = true;
      host = "0.0.0.0";
      port = 10000;
      # TODO: enable this to delete all settings made from the web-interface
      # this needs to have much more options defined as this will be the complete config
      mutableSettings = true;
      allowDHCP = true;
      settings = {
        dns = {
          upstream_dns = [
            "quic://dns-unfiltered.adguard.com:784"
            "https://dns.cloudflare.com/dns-query"
            "https://dns10.quad9.net/dns-query"
          ];
        };
        user_rules = [
          "||${hcfg.domain}^$dnsrewrite=NOERROR;A;${hcfg.serverIP},client=${hcfg.subnet}"
        ] ++ (lib.optionals hcfg.tailscale.enable [
          "||${hcfg.domain}^$dnsrewrite=NOERROR;A;${hcfg.tailscale.serverIP},client=${hcfg.tailscale.subnet}"
        ]);
      };
    };

    # Open ports for DNS server and dhcp
    # networking.firewall.allowedUDPPorts = [ 53 67 ];
    networking.firewall.allowedUDPPorts = [ 53 ];

    # The leases contain also the static addresses
    # homelab.backup.stateDirs = [ "${baseDir}/data/leases.json" ];

    homelab.traefik.routes = [{
      host = cfg.domain;
      port = 10000;
    }];

    homelab.homepage.services = [{
      AdGuard = {
        icon = "adguard-home.png";
        href = "https://${dname}";
        siteMonitor = "https://${dname}";
        description = "DNS server";
      };
    }];
  };
}
