{ config, ... }:
let
  cfg = config.homelab.traefik;

  createRoutes = builtins.listToAttrs (map ({ host, ... }: {
    name = "${host}-rtr";
    value = {
      entryPoints = "websecure";
      rule = "Host(`${host}.${config.homelab.domain}`)";
      service = "${host}-srv";
    };
  }) cfg.routes);

  createServices = builtins.listToAttrs (map ({ host, port }: {
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
        "synology-rtr" = {
          entryPoints = "websecure";
          rule = "Host(`nas.${config.homelab.domain}`)";
          service = "synology-srv";
        };
        "ha-rtr" = {
          entryPoints = "websecure";
          rule = "Host(`ha.${config.homelab.domain}`)";
          service = "ha-srv";
        };
      } // createRoutes;
      services = {
        "synology-srv".loadBalancer.servers =
          [{ url = "http://${config.homelab.smbServerIP}:5000"; }];
        "ha-srv".loadBalancer.servers =
          [{ url = "http://192.168.1.125:8123"; }];
      } // createServices;
    };
  };

  # Set up with authelia
  homelab.authelia.bypassDomains =
    [ "nas.${config.homelab.domain}" "ha.${config.homelab.domain}" ];

}
