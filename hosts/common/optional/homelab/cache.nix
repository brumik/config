{ config, lib, ... }:
let
  cfg = config.homelab.cache;
  hcfg = config.homelab;
  dname = "${cfg.domain}.${hcfg.domain}";
in {
  options.homelab.cache = {
    enable = lib.mkEnableOption "Cache server for nixos";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "cache";
      description = "The subdomain where the service will be served";
    };
  };

  config = lib.mkIf cfg.enable {
    sops.secrets = { "private-keys/cache-private-key-pem" = { }; };

    services.nix-serve = {
      enable = true;
      bindAddress = "localhost";
      port = 11117;
      secretKeyFile =
        config.sops.secrets."private-keys/cache-private-key-pem".path;
    };

    homelab.traefik.routes = [{
      host = cfg.domain;
      port = 11117;
    }];

    homelab.authelia.localBypassDomains = [ dname ];
  };
}
