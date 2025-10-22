{ config, lib, ... }:
let
  cfg = config.homelab.media.soulseek;
  hcfg = config.homelab;
  dname = "${cfg.domain}.${hcfg.domain}";
in {
  options.homelab.media.soulseek = {
    enable = lib.mkEnableOption "soulseek";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "soulseek";
      description = "The subdomain where the service will be served";
    };

    baseDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/oci-soulseek";
      description =
        "The absolute path where the service will store the important informations";
    };
  };

  config = lib.mkIf (hcfg.enable && hcfg.media.enable && cfg.enable) {
    systemd.tmpfiles.rules = [
      "d ${cfg.baseDir} ${hcfg.user} ${hcfg.group} -"
    ];

    assertions = [{
      assertion = hcfg.media.gluetun.enable;
      message = "Transmission depends on gluetun";
    }];

    virtualisation.oci-containers.containers = {
      gluetun.ports = [
        # For soulseek since the networking is going through this container
        "5030:5030"
        "50300:50300"
      ];

      ####################################################
      # Most of the configuration for this service is 
      # happening in the settings.json file. We should
      # back that file up, but with different settings
      # or mounting this file might be outdated.
      ####################################################
      soulseek = {
        image = "slskd/slskd:latest";
        pull = "always";
        environment = {
          SLSKD_REMOTE_CONFIGURATION = "true";

          # To update the port forwarding port from the gluetun container
          # DOCKER_MODS =
          #   "ghcr.io/michsior14/docker-mods:soulseek-gluetun-port-update";
          # PUID =
          #   builtins.toString config.users.users."${config.homelab.user}".uid;
          # PGID =
          #   builtins.toString config.users.groups."${config.homelab.group}".gid;
          # TZ = "Europe/Berlin";
        };
        volumes = [
          "${cfg.baseDir}:/app"
          # This is so all the other native apps (lidarr etc) see the directory
          "${hcfg.media.torrentDir}:/${hcfg.media.torrentDir}"
        ];
        # This makes it share gluetun's network namespace:
        extraOptions = [ "--network=container:gluetun" ];
      };
    };

    homelab.traefik.routes = [{
      host = cfg.domain;
      port = 5030;
    }];

    homelab.backup.stateDirs = [ cfg.baseDir ];

    homelab.homepage.arr = [{
      Soulseek = {
        icon = "soulseek.png";
        href = "https://${dname}";
        siteMonitor = "https://${dname}";
        description = "Soulseek Torrenting Client";
      };
    }];
  };
}
