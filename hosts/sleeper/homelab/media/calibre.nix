{ config, lib, ... }:
let
  cfg = config.homelab.media.calibre;
  hcfg = config.homelab;
  dir = cfg.baseDir;
in {
  options.homelab.media.calibre = {
    enable = lib.mkEnableOption "calibre";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "books";
      description = "The subdomain where the service will be served";
    };

    baseDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/oci-calibre";
      description = "The absolute path where the service will store the important informations";
    };
  };

  config = lib.mkIf (hcfg.enable && hcfg.media.enable && cfg.enable) {
    # Create directories
    systemd.tmpfiles.rules = [
      "d ${dir} 0755 share share -"
      "d ${dir}/calibre 0755 share share -"
      "d ${dir}/calibre/Calibre\\ Library 0755 share share -"
      "d ${dir}/calibre-web 0755 share share -"
    ];

    virtualisation.oci-containers.containers."calibre" = {
      image = "lscr.io/linuxserver/calibre:latest";
      pull = "always";
      ports = [ "11080:8080" ];
      environment = {
        TZ = "${config.time.timeZone}";
        PUID =
          builtins.toString config.users.users."${config.homelab.user}".uid;
        PGID =
          builtins.toString config.users.groups."${config.homelab.group}".gid;
      };
      volumes = [ "${dir}/calibre:/config" ];
    };

    # TODO: this will fail on empty calibre library
    # solution: wait until calibre starts up and creates an empty library on a new server
    virtualisation.oci-containers.containers."calibre-web" = {
      image = "lscr.io/linuxserver/calibre-web:latest";
      pull = "always";
      ports = [ "11083:8083" ];
      environment = {
        TZ = "${config.time.timeZone}";
        PUID =
          builtins.toString config.users.users."${config.homelab.user}".uid;
        PGID =
          builtins.toString config.users.groups."${config.homelab.group}".gid;
      };
      volumes = [
        "${dir}/calibre-web:/config"
        "${dir}/calibre/Calibre Library:/books"
      ];
    };

    homelab.traefik.routes = [
      {
        host = "calibre";
        port = 11080;
      }
      {
        host = cfg.domain;
        port = 11083;
      }
    ];

    homelab.authelia.exposedDomains = [ "${cfg.domain}.${config.homelab.domain}" ];

    homelab.backup.stateDirs = [ dir ];

    homelab.homepage.media = [
      {
        "Calibre Web" = {
          icon = "calibre-web.png";
          href = "https://${cfg.domain}.${config.homelab.domain}";
          siteMonitor = "https://${cfg.domain}.${config.homelab.domain}";
          description = "Ebook reading services";
        };
      }
      {
        "Calibre" = {
          icon = "calibre.png";
          href = "https://calibre.${config.homelab.domain}";
          siteMonitor = "https://calibre.${config.homelab.domain}";
          description = "Ebook management software";
        };
      }
    ];
  };
}
