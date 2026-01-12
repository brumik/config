{ config, lib, ... }:
let
  cfg = config.homelab.monitoring;
  # hcfg = config.homelab;
  dname = "grafana.${config.homelab.domain}";
in {
  imports = [ ];

  options.homelab.monitoring = { enable = lib.mkEnableOption "monitoring"; };

  config = lib.mkIf cfg.enable {
    services.prometheus = {
      enable = true;
      port = 9093;

      exporters = {
        node = {
          port = 9002;
          enabledCollectors = [ "systemd" ];
          enable = true;
        };
      };

      # ingest the published nodes
      scrapeConfigs = [{
        job_name = "sleeper";
        static_configs = [{
          targets = [
            "127.0.0.1:${
              toString config.services.prometheus.exporters.node.port
            }"
          ];
        }];
      }];
    };

    # loki: port 3030 (8030)
    #
    services.loki = {
      enable = true;
      configuration = {
        server.http_listen_port = 3030;
        auth_enabled = false;

        ingester = {
          lifecycler = {
            address = "127.0.0.1";
            ring = {
              kvstore = { store = "inmemory"; };
              replication_factor = 1;
            };
          };
          chunk_idle_period = "1h";
          max_chunk_age = "1h";
          chunk_target_size = 999999;
          chunk_retain_period = "30s";
        };

        schema_config = {
          configs = [{
            from = "2026-01-11";
            store = "tsdb";
            object_store = "filesystem";
            schema = "v13";
            index = {
              prefix = "index_";
              period = "24h";
            };
          }];
        };

        storage_config = {
          tsdb_shipper = {
            active_index_directory = "/var/lib/loki/tsdb-active";
            cache_location = "/var/lib/loki/tsdb-cache";
            cache_ttl = "24h";
          };

          filesystem = { directory = "/var/lib/loki/chunks"; };
        };

        limits_config = {
          reject_old_samples = true;
          reject_old_samples_max_age = "168h";
        };

        compactor = {
          working_directory = "/var/lib/loki";
        };
      };
      # user, group, dataDir, extraFlags, (configFile)
    };

    # promtail: port 3031 (8031)
    #
    services.promtail = {
      enable = true;
      configuration = {
        server = {
          http_listen_port = 3031;
          grpc_listen_port = 0;
        };
        positions = { filename = "/tmp/positions.yaml"; };
        clients = [{
          url = "http://127.0.0.1:${
              toString
              config.services.loki.configuration.server.http_listen_port
            }/loki/api/v1/push";
        }];
        scrape_configs = [{
          job_name = "journal";
          journal = {
            max_age = "12h";
            labels = {
              job = "systemd-journal";
              host = "sleeper";
            };
          };
          relabel_configs = [{
            source_labels = [ "__journal__systemd_unit" ];
            target_label = "unit";
          }];
        }];
      };
      # extraFlags
    };

    # grafana: port 3010 (8010)
    #
    services.grafana = { };

    services.grafana = {
      enable = true;
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
      host = "grafana";
      port = config.services.grafana.settings.server.http_port;
    }];
  };
}
