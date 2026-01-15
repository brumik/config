{ config, lib, ... }:
let
  hcfg = config.homelab;
  mhcfg = hcfg.monitoring;
  cfg = mhcfg.grafana;
  dname = "${cfg.domain}.${hcfg.domain}";
  grafana = config.globals.users.grafana;
in {
  options.homelab.monitoring.grafana = {
    domain = lib.mkOption {
      type = lib.types.str;
      default = "grafana";
      description = "The subdomain where the service will be served";
    };

    baseDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/grafana";
      description =
        "The absolute path where the service will store the important informations";
    };
  };

  config = lib.mkIf (hcfg.enable && mhcfg.enable) {
    users = {
      groups.${grafana.gname} = { gid = grafana.gid; };
      users.${grafana.uname} = { uid = grafana.uid; };
    };

    services.grafana = {
      enable = true;
      dataDir = cfg.baseDir;
      settings = {
        analytics.reporting_enable = false;
        server = {
          http_addr = "127.0.0.1";
          http_port = 3000;
          domain = dname;
        };
      };

      provision = {
        enable = true;
        datasources.settings = {
          apiVersion = 1;
          datasources = [
            {
              name = "Prometheus";
              type = "prometheus";
              access = "proxy";
              url =
                "http://127.0.0.1:${toString config.services.prometheus.port}";
            }
            {
              name = "Loki";
              type = "loki";
              access = "proxy";
              url = "http://127.0.0.1:${
                  toString
                  config.services.loki.configuration.server.http_listen_port
                }";
            }
          ];
        };
      };
    };

    homelab.traefik.routes = [{
      host = cfg.domain;
      port = config.services.grafana.settings.server.http_port;
    }];

    homelab.backup.stateDirs = [ cfg.baseDir ];

    homelab.homepage.admin = [{
      Grafana = {
        icon = "grafana.png";
        href = "https://${dname}";
        siteMonitor = "https://${dname}";
        description = "Monitoring site";
      };
    }];
  };
}
