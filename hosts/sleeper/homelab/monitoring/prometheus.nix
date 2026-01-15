{ config, lib, ... }:
let
  hcfg = config.homelab;
  mhcfg = hcfg.monitoring;

  disks = config.mySystems.disks;
  basename = diskPath: builtins.elemAt (lib.strings.splitString "/" diskPath) (builtins.length (lib.strings.splitString "/" diskPath) - 1);
  mkDiskRelabel = device: disk_name: {
    source_labels = [ "device" ];
    regex = (basename device);
    target_label = "human_name";
    replacement = disk_name;
  };
in {
  config = lib.mkIf (hcfg.enable && mhcfg.enable) {
    sops.secrets."n100/prometheus/hetzner-token" = {};

    services.prometheus = {
      enable = true;
      # extraFlags = [ "--web.enable-admin-api" ];
      port = 9093;

      exporters = {
        apcupsd.enable = true;
        zfs.enable = true;
        storagebox = {
          enable = true;
          tokenFile = config.sops.secrets."n100/prometheus/hetzner-token".path;
        };
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
          job_name = "storagebox";
          static_configs = [{
            targets = [
              "127.0.0.1:${
                toString config.services.prometheus.exporters.storagebox.port
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
  };
}
