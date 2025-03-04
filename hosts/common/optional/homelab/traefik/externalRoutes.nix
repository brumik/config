{ config, ... }: {
  services.traefik = {
    dynamicConfigOptions.http = {
      routers = {
        "traefik-rtr" = {
          entryPoints = "websecure";
          rule = "Host(`traefik.${config.homelab.domain}`)";
          service = "api@internal";
          # TODO Middleware
        };
        "synology-rtr" = {
          entryPoints = "websecure";
          rule = "Host(`nas.${config.homelab.domain}`)";
          service = "synology-srv";
          # TODO Middleware
        };
        "ha-rtr" = {
          entryPoints = "websecure";
          rule = "Host(`ha.${config.homelab.domain}`)";
          service = "ha-srv";
          # TODO Middleware
        };
      };
      services = {
        "synology-srv".loadBalancer.servers =
          [{ url = "http://${config.homelab.smbServerIP}:5000"; }];
        "ha-srv".loadBalancer.servers =
          [{ url = "http://192.168.1.125:8123"; }];
      };
    };
  };
}
