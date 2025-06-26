{ config, ... }:
let
  cfg = config.homelab.traefik;

  createRoutes = builtins.listToAttrs (map ({ host, local, ... }: {
    name = "${host}-rtr";
    value = {
      entryPoints = "websecure";
      rule = "Host(`${host}.${config.homelab.domain}`)";
      middlewares = [ (if local then "chain-authelia-local" else "chain-authelia") ];
      service = "${host}-srv";
    };
  }) cfg.routes);

  createServices = builtins.listToAttrs (map ({ host, port, ... }: {
    name = "${host}-srv";
    value = {
      loadBalancer.servers =
        [{ url = "http://127.0.0.1:${builtins.toString port}"; }];
    };
  }) cfg.routes);
in {
  services.traefik = {
    dynamicConfigOptions.http = {
      routers = {
        "traefik-rtr" = {
          entryPoints = "websecure";
          rule = "Host(`traefik.${config.homelab.domain}`)";
          service = "api@internal";
        };
      } // createRoutes;
      services = {
      } // createServices;
    };
  };

  homelab.homepage.admin = [{
    Traefik = {
      icon = "traefik.png";
      href = "https://${cfg.domain}.${config.homelab.domain}";
      siteMonitor = "https://${cfg.domain}.${config.homelab.domain}";
      description = "Reverse proxy dashboard (read only)";
    };
  }];
}
