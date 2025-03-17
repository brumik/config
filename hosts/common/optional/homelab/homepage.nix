{ config, lib, ... }:
let cfg = config.homelab.homepage;
in {
  options.homelab.homepage = { enable = lib.mkEnableOption "homepage"; };

  config = lib.mkIf cfg.enable {
    services.homepage-dashboard = {
      enable = true;
      # listenPort = 8082;
      services = [
        { Admin = [ ]; }
        { Media = [ ]; }
        { Services = [ ]; }
        { App = [ ]; }
      ];
      widgets = [
        {
          resources = {
            cpu = true;
            disk = "/";
            memory = true;
          };
        }
        {
          search = {
            provider = "duckduckgo";
            target = "_blank";
          };
        }
      ];
    };

    # Traefik custom config contains this service on the default domain
    services.traefik.dynamicConfigOptions.http = {
      routers = {
        "homepage-rtr" = {
          entryPoints = "websecure";
          rule = "Host(`${config.homelab.domain}`)";
          service = "homepage-srv";
        };
      };
      services = {
        "homepage-srv".loadBalancer.servers =
          [{ url = "http://127.0.0.1:8082"; }];
      };
    };
  };
}
