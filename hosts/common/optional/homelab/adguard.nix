{ config, lib, ... }:
let cfg = config.homelab.adguardhome;
in {
  options.homelab.adguardhome = { enable = lib.mkEnableOption "adguard"; };

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

    homelab.traefik.routes = [{
      host = "adguard";
      port = 10000;
    }];

    homelab.homepage.services = [{
      AdGuard = {
        icon = "adguard-home.png";
        href = "https://adguard.berky.me";
        siteMonitor = "https://adguard.berky.me";
        description = "DNS server";
      };
    }];
  };
}
