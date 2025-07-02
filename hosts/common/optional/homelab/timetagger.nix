{ config, lib, ... }:
let
  cfg = config.homelab.timetagger;
  hcfg = config.homelab;
  dname = "${cfg.domain}.${hcfg.domain}";
in {
  options.homelab.timetagger = {
    enable = lib.mkEnableOption "timetagger";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "time";
      description = "The subdomain where the service will be served";
    };

    baseDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/timetagger-oci";
      description =
        "The absolute path where the service will store the important informations";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = [ "d ${cfg.baseDir} 0755 share share -" ];

    virtualisation.oci-containers.containers.timetagger = {
      image = "ghcr.io/almarklein/timetagger";
      extraOptions = [ "--pull=always" ];
      ports = [ "11115:80" ];
      environment = {
        TIMETAGGER_BIND = "0.0.0.0:80";
        TIMETAGGER_DATADIR = "/root/_timetagger";
        TIMETAGGER_LOG_LEVEL = "info";
        TIMETAGGER_PROXY_AUTH_ENABLED = "True";
        # TIMETAGGER_PROXY_AUTH_TRUSTED = "host.docker.internal";
        TIMETAGGER_PROXY_AUTH_TRUSTED = "172.0.0.0/8";
        TIMETAGGER_PROXY_AUTH_HEADER = "Remote-User";
      };
      volumes = [ "${cfg.baseDir}:/root/_timetagger" ];
    };

    homelab.backup.stateDirs = [ cfg.baseDir ];

    homelab.traefik.routes = [{
      host = cfg.domain;
      port = 11115;
    }];

    homelab.authelia.exposedDomains = [ dname ];

    homelab.homepage.app = [{
      Timetagger = {
        icon = "timetagger.png";
        href = "https://${dname}";
        siteMonitor = "https://${dname}";
        description = "Time tracking software";
      };
    }];
  };
}
