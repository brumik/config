{ config, ... }: {
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
      };
      services = {
        "synology-srv".loadBalancer.servers =
          [{ url = "http://${config.homelab.smbServerIP}:5000"; }];
        "ha-srv".loadBalancer.servers =
          [{ url = "http://192.168.1.125:8123"; }];
      };
    };
  };

  # Set up with authelia
  homelab.authelia.bypassDomains = [
    "nas.${config.homelab.domain}"
    "ha.${config.homelab.domain}"
  ];

}
