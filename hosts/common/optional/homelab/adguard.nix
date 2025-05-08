{ config, lib, ... }:
let
  cfg = config.homelab.adguardhome;
  hcfg = config.homelab;
  dname = "${cfg.domain}.${hcfg.domain}";
in {
  options.homelab.adguardhome = {
    enable = lib.mkEnableOption "adguard";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "adguard";
      description = "The subdomain where the service will be served";
    };
  };

  config = lib.mkIf cfg.enable {
    services.adguardhome = {
      enable = true;
      host = "0.0.0.0";
      port = 10000;
      # TODO: enable this to delete all settings made from the web-interface
      # this needs to have much more options defined as this will be the complete config
      mutableSettings = true;
      settings = {
        dns = {
          upstream_dns = [
            "quic://dns-unfiltered.adguard.com:784"
            "https://dns.cloudflare.com/dns-query"
            "https://dns10.quad9.net/dns-query"
          ];
        };
        filtering = {
          rewrites = [
            {
              domain = "*.${config.homelab.domain}";
              answer = "${config.homelab.serverIP}";
            }
            {
              domain = "${config.homelab.domain}";
              answer = "${config.homelab.serverIP}";
            }
          ];
        };
      };
    };

    # Open ports for DNS server
    networking.firewall.allowedUDPPorts = [ 53 ];

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
