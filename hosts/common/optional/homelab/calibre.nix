{ config, lib, ... }:
let
  cfg = config.homelab.calibre;
  dir = "/var/lib/oci-calibre";
in {
  options.homelab.calibre = { enable = lib.mkEnableOption "calibre"; };

  config = lib.mkIf cfg.enable {
    # Create directories
    systemd.tmpfiles.rules = [
      "d ${dir} 0755 share share -"
      "d ${dir}/calibre 0755 share share -"
      "d ${dir}/calibre/Calibre\\ Library 0755 share share -"
      "d ${dir}/calibre-web 0755 share share -"
    ];

    virtualisation.oci-containers.containers."calibre" = {
      image = "lscr.io/linuxserver/calibre:latest";
      ports = [ "11080:8080" ];
      environment = {
        TZ = "${config.time.timeZone}";
        PUID =
          builtins.toString config.users.users."${config.homelab.user}".uid;
        PGID =
          builtins.toString config.users.groups."${config.homelab.group}".gid;
      };
      volumes = [ "/mnt/video/Ebooks:/config/books" "${dir}/calibre:/config" ];
    };

    virtualisation.oci-containers.containers."calibre-web" = {
      image = "lscr.io/linuxserver/calibre-web:latest";
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
        host = "books";
        port = 11083;
      }
    ];

    homelab.authelia.exposedDomains = [ "books.${config.homelab.domain}" ];

    homelab.backup.stateDirs = [ dir ];

    homelab.homepage.app = [
      {
        "Calibre Web" = {
          icon = "calibre-web.png";
          href = "https://books.${config.homelab.domain}";
          siteMonitor = "https://books.${config.homelab.domain}";
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
