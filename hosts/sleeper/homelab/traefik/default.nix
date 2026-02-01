{ config, lib, ... }:
let
  types = lib.types;
  cfg = config.homelab.traefik;
  hcfg = config.homelab;
in {
  imports = [ ./middlewares.nix ./externalRoutes.nix ];

  options.homelab.traefik = {
    enable = lib.mkEnableOption "traefik";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "traefik";
      description = "The subdomain where the service will be served";
    };

    routes = lib.mkOption {
      type = types.listOf (types.submodule ({ ... }: {
        options = {
          port = lib.mkOption {
            type = types.int;
            description = "Port number for the service.";
          };
          host = lib.mkOption {
            type = types.str;
            description = "Host address for the service.";
          };
          local = lib.mkOption {
            type = types.bool;
            default = false;
            description = "If it should be marked as a local only route, skipping some security features";
          };
        };
      }));
      default = [ ];
    };
  };

  config = lib.mkIf (hcfg.enable && cfg.enable) {
    sops.secrets = { "n100/traefik/websupport-secret" = { }; };
    sops.templates."n100/traefik/.env" = {
      content = ''
        WEBSUPPORT_SECRET=${
          config.sops.placeholder."n100/traefik/websupport-secret"
        }
        WEBSUPPORT_API_KEY=a154f3f6-b7cc-49d4-9db7-40b1f99bc0ce
        LEGO_DISABLE_CNAME_SUPPORT=true
      '';
    };

    services.traefik = {
      enable = true;
      dataDir = "/var/lib/traefik";
      staticConfigOptions = {
        api.dashboard = true;

        # DEBUG, INFO, WARN, ERROR, FATAL, PANIC
        log.level = "INFO";

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
                sans = [ "*.${config.homelab.domain}" ];
              }];
            };
            transport.respondingTimeouts = {
            # This is needed for example for immich to upload videos or files that takes longer than 30s.
            # this allows the connection to stay alive 10m
              readTimeout = "600s";
              idleTimeout = "600s";
              writeTimeout = "600s";
            };
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
    };
  };
}
