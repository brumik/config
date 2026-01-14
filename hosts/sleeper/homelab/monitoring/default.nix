{ config, lib, ... }:
let
  cfg = config.homelab.monitoring;
  dname = "grafana.${config.homelab.domain}";
  disks = config.mySystems.disks;
  basename = diskPath: builtins.elemAt (lib.strings.splitString "/" diskPath) (builtins.length (lib.strings.splitString "/" diskPath) - 1);
  mkDiskRelabel = device: disk_name: {
    source_labels = [ "device" ];
    regex = (basename device);
    target_label = "human_name";
    replacement = disk_name;
  };
in {
  imports = [ ];

  options.homelab.monitoring = { enable = lib.mkEnableOption "monitoring"; };

  config = lib.mkIf cfg.enable {
    services.prometheus = {
      enable = true;
      # extraFlags = [ "--web.enable-admin-api" ];
      port = 9093;

      exporters = {
        apcupsd.enable = true;
        zfs.enable = true;
        smartctl = {
          enable = true;
          devices = [
            disks.rootDisk1
            disks.rootDisk2
            disks.dataDisk1
            disks.dataDisk2
            disks.dataSpare
            disks.dataCache
          ];
        };
        node = {
          port = 9002;
          enabledCollectors = [ "systemd" ];
          enable = true;
        };
      };

      # ingest the published nodes
      scrapeConfigs = [
        {
          job_name = "apcupsd";
          static_configs = [{
            targets = [
              "127.0.0.1:${
                toString config.services.prometheus.exporters.apcupsd.port
              }"
            ];
          }];
        }
        {
          job_name = "zfs";
          static_configs = [{
            targets = [
              "127.0.0.1:${
                toString config.services.prometheus.exporters.zfs.port
              }"
            ];
          }];
        }
        {
          job_name = "sleeper";
          static_configs = [{
            targets = [
              "127.0.0.1:${
                toString config.services.prometheus.exporters.node.port
              }"
            ];
          }];
        }
        {
          job_name = "smartctl";
          static_configs = [{
            targets = [
              "127.0.0.1:${
                toString config.services.prometheus.exporters.smartctl.port
              }"
            ];
          }];
          metric_relabel_configs = [
            (mkDiskRelabel disks.rootDisk1 "rootDisk1")
            (mkDiskRelabel disks.rootDisk2 "rootDisk2")
            (mkDiskRelabel disks.dataDisk1 "dataDisk1")
            (mkDiskRelabel disks.dataDisk2 "dataDisk2")
            (mkDiskRelabel disks.dataSpare "dataSpare")
            (mkDiskRelabel disks.dataCache "dataCache")
          ];
        }
        # {
        #   job_name = "immich_api";
        #   static_configs = [{
        #     targets = [
        #       "127.0.0.1:${
        #         toString
        #         config.services.immich.environment.IMMICH_API_METRICS_PORT
        #       }"
        #     ];
        #   }];
        # }
        # {
        #   job_name = "immich_microservices";
        #   static_configs = [{
        #     targets = [
        #       "127.0.0.1:${
        #         toString
        #         config.services.immich.environment.IMMICH_MICROSERVICES_METRICS_PORT
        #       }"
        #     ];
        #   }];
        # }
      ];
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

        compactor = { working_directory = "/var/lib/loki"; };
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
