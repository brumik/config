{ config, lib, ... }:
let
  cfg = config.homelab.traefik;
  createRouter = { name, port }: {
    dynamicConfigOptions.http = {
      routers."${name}-rtr" = {
        entryPoints = "websecure";
        rule = "Host(`${name}.${config.homelab.domain}`)";
        service = "${name}-srv";
        # TODO Middleware
      };
      services."${name}-srv".loadBalancer.servers.url = "127.0.0.1:${port}";
    };
  };
in {
  options.homelab.traefik = { 
    enable = lib.mkEnableOption "traefik";
    createRouter = lib.mkOption {
      default = createRouter;
    };
  };

  config = lib.mkIf cfg.enable {
    sops.secrets = { "n100/traefik/websupport-secret" = { }; };
    sops.templates."n100/traefik/.env" = {
      content = ''
        WEBSUPPORT_SECRET=${
          config.sops.placeholder."n100/traefik/websupport-secret"
        }
        WEBSUPPORT_API_KEY=a154f3f6-b7cc-49d4-9db7-40b1f99bc0ce
      '';
    };

    services.traefik = {
      enable = true;
      dataDir = "/var/lib/traefik";
      staticConfigOptions = {
        api.dashboard = true;

        # DEBUG, INFO, WARN, ERROR, FATAL, PANIC
        log.level = "WARN";

        entrypoints = {
          traefik.address = ":8080";
          web = {
            address = ":80";
            http.redirections.entrypoint = {
              to = "websecure";
              scheme = "https";
              permanent = true;
            };
          };
          websecure = {
            address = ":443";
            http.tls = {
              certresolver = "websupportletsencrypt";
              domains = [{
                main = config.homelab.domain;
                sans = ["*.${config.homelab.domain}"];
              }];
            };
            transport.respondingTimeouts = {
              readTimeout = 600;
              writeTimeout = 600;
              idleTimeout = 600;
            };
            forwardedHeaders.trustedIPs =
              [ "127.0.0.1/32" "10.0.0.0/8" "192.168.0.0/16" ];
          };
        };

        certificatesResolvers.websupportletsencrypt.acme = {
          # For staging, comment out for production
          # caServer = "https://acme-staging.api.letsencrypt.org/directory";
          email = "levente.berky@gmail.com";
          storage = "/var/lib/traefik/acme.json";

          dnsChallenge = {
            provider = "websupport";
            resolvers = [ "1.1.1.1:53" ];
          };
        };
      };
      environmentFiles = [ config.sops.templates."n100/traefik/.env".path ];
    } // createRouter {
      name = "traefik";
      port = "8080";
    };
  };
}
