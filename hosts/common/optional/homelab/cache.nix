{ config, ... }:

{
  sops.secrets = {
    "private-keys/cache-private-key-pem" = { };
  };

  services.nix-serve = {
    enable = true;
    bindAddress = "localhost";
    port = 11117;
    secretKeyFile = config.sops.secrets."private-keys/cache-private-key-pem".path;
  };

  homelab.traefik.routes = [{
    host = "cache";
    port = 11117;
  }];

  homelab.authelia.localBypassDomains = [ "cache.berky.me" ];
}
