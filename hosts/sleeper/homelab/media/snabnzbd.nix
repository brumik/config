{ config, lib, ... }:
let
  cfg = config.homelab.media.sabnzbd;
  hcfg = config.homelab;
  dname = "${cfg.domain}.${hcfg.domain}";
in {
  options.homelab.media.sabnzbd = {
    enable = lib.mkEnableOption "sabnzbd";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "sabnzbd";
      description = "The subdomain where the service will be served";
    };

    baseDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/oci-sabnzbd";
      description =
        "The absolute path where the service will store the important informations";
    };
  };

  config = lib.mkIf (hcfg.enable && hcfg.media.enable && cfg.enable) {
    systemd.tmpfiles.rules = [
      # "d '${nixarr.mediaDir}/torrents/sonarr'      0755 ${globals.transmission.user} ${globals.transmission.group} - -"
      # "d '${nixarr.mediaDir}/torrents/readarr'     0755 ${globals.transmission.user} ${globals.transmission.group} - -"
      "d ${hcfg.media.usenetDir}/.incomplete 0775 ${hcfg.user} ${hcfg.group} -"
      "d ${hcfg.media.usenetDir}/.watch 0775 ${hcfg.user} ${hcfg.group} -"
      "d ${hcfg.media.usenetDir}/manual 0775 ${hcfg.user} ${hcfg.group} -"
      "d ${hcfg.media.usenetDir}/lidarr 0775 ${hcfg.user} ${hcfg.group} -"
      "d ${hcfg.media.usenetDir}/radarr 0775 ${hcfg.user} ${hcfg.group} -"
    ];

    assertions = [{
      assertion = hcfg.media.gluetun.enable;
      message = "Sabnzbd depends on gluetun";
    }];

    virtualisation.oci-containers.containers = {
      gluetun.ports = [
        # For transmission since the networking is going through this container
        "9093:8080"
      ];

      ####################################################
      # Most of the configuration for this service is 
      # happening in the settings.json file. We should
      # back that file up, but with different settings
      # or mounting this file might be outdated.
      ####################################################
      sabnzbd = {
        image = "lscr.io/linuxserver/sabnzbd:latest";
        pull = "always";
        environment = {
          PUID =
            builtins.toString config.users.users."${config.homelab.user}".uid;
          PGID =
            builtins.toString config.users.groups."${config.homelab.group}".gid;
          TZ = "Europe/Berlin";
        };
        volumes = [
          "${cfg.baseDir}:/config"
          # This is so all the other native apps (lidarr etc) see the directory
          "${hcfg.media.usenetDir}:/${hcfg.media.usenetDir}"
        ];
        # This makes it share gluetun's network namespace:
        extraOptions = [ "--network=container:gluetun" ];
      };
    };

    homelab.traefik.routes = [{
      host = cfg.domain;
      port = 9093;
    }];

    homelab.backup.stateDirs = [ cfg.baseDir ];

    homelab.homepage.arr = [{
      Sabnzbd = {
        icon = "sabnzbd.png";
        href = "https://${dname}";
        siteMonitor = "https://${dname}";
        description = "Sabnzbd Usenet Client";
      };
    }];
  };
}
