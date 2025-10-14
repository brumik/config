{ config, lib, ... }:
let
  cfg = config.homelab.media.transmission;
  hcfg = config.homelab;
  dname = "${cfg.domain}.${hcfg.domain}";
in {
  options.homelab.media.transmission = {
    enable = lib.mkEnableOption "transmission";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "transmission";
      description = "The subdomain where the service will be served";
    };

    baseDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/oci-transmission";
      description =
        "The absolute path where the service will store the important informations";
    };
  };

  config = lib.mkIf (hcfg.enable && hcfg.media.enable && cfg.enable) {
    sops.secrets."n100/protonvpn-wireguard-private-key" = { };
    sops.templates."n100/gluetun/.env" = {
      content = ''
        WIREGUARD_PRIVATE_KEY=${
          config.sops.placeholder."n100/protonvpn-wireguard-private-key"
        }
      '';
    };

    systemd.tmpfiles.rules = [
      # "d '${nixarr.mediaDir}/torrents/sonarr'      0755 ${globals.transmission.user} ${globals.transmission.group} - -"
      # "d '${nixarr.mediaDir}/torrents/readarr'     0755 ${globals.transmission.user} ${globals.transmission.group} - -"
      "d ${hcfg.media.torrentDir}/.incomplete 0775 ${hcfg.user} ${hcfg.group} -"
      "d ${hcfg.media.torrentDir}/.watch 0775 ${hcfg.user} ${hcfg.group} -"
      "d ${hcfg.media.torrentDir}/manual 0775 ${hcfg.user} ${hcfg.group} -"
      "d ${hcfg.media.torrentDir}/lidarr 0775 ${hcfg.user} ${hcfg.group} -"
      "d ${hcfg.media.torrentDir}/radarr 0775 ${hcfg.user} ${hcfg.group} -"
    ];

    virtualisation.oci-containers.containers = {
      gluetun = {
        image = "qmcgaw/gluetun";
        pull = "always";
        capabilities = { NET_ADMIN = true; };
        ports = [
          # For transmission since the networking is going through this container
          "9092:9091"
          "51413:51413"
          "51413:51413/udp"
        ];
        environment = {
          VPN_SERVICE_PROVIDER = "protonvpn";
          VPN_TYPE = "wireguard";
          SERVER_COUNTRIES = "Germany";
          VPN_PORT_FORWARDING = "on";
        };
        environmentFiles = [ config.sops.templates."n100/gluetun/.env".path ];
        devices = [ "/dev/net/tun:/dev/net/tun" ];
      };

      ####################################################
      # Most of the configuration for this service is 
      # happening in the settings.json file. We should
      # back that file up, but with different settings
      # or mounting this file might be outdated.
      ####################################################
      transmission = {
        image = "lscr.io/linuxserver/transmission:latest";
        pull = "always";
        environment = {
          # To update the port forwarding port from the gluetun container
          DOCKER_MODS =
            "ghcr.io/michsior14/docker-mods:transmission-gluetun-port-update";
          PUID =
            builtins.toString config.users.users."${config.homelab.user}".uid;
          PGID =
            builtins.toString config.users.groups."${config.homelab.group}".gid;
          TZ = "Europe/Berlin";
        };
        volumes = [
          "${cfg.baseDir}:/config"
          # This is so all the other native apps (lidarr etc) see the directory
          "${hcfg.media.torrentDir}:/${hcfg.media.torrentDir}"
        ];
        # This makes it share gluetun's network namespace:
        extraOptions = [ "--network=container:gluetun" ];
      };
    };

    homelab.traefik.routes = [{
      host = cfg.domain;
      port = 9092;
    }];

    homelab.backup.stateDirs = [ cfg.baseDir ];

    homelab.homepage.arr = [{
      Transmission = {
        icon = "transmission.png";
        href = "https://${dname}";
        siteMonitor = "https://${dname}";
        description = "Transmission Torrenting Client";
      };
    }];
  };
}
