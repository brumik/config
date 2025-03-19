{ config, lib, ... }:
let cfg = config.homelab.homepage;
in {
  options.homelab.homepage = {
    enable = lib.mkEnableOption "homepage";
    app = lib.mkOption {
      default = [ ];
    };
    admin = lib.mkOption {
      default = [ ];
    };
    services = lib.mkOption {
      default = [ ];
    };
  };

  config = lib.mkIf cfg.enable {
    services.homepage-dashboard = {
      enable = true;
      # listenPort = 8082;
      services = [
        { App = cfg.app; }
        { Admin = cfg.admin ++ cfg.services; }
        # { Services = cfg.services; }
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
