{ config, lib, ... }:
let
  cfg = config.homelab.adguardhome;
in {
  options.homelab.adguardhome = {
    enable = lib.mkEnableOption "adguard";
  };

  config = lib.mkIf cfg.enable {
    services.adguardhome = {
      enable = true;
      host = "0.0.0.0";
      port = 10000;
      openFirewall = true;
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
  };
}
