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
      "d ${hcfg.media.libDir}/music 0775 ${hcfg.user} ${hcfg.group} -"
      "d ${hcfg.media.torrentDir}/soulseek 0775 ${hcfg.user} ${hcfg.group} -"
      "d ${hcfg.media.torrentDir}/.soulseek_incomplete 0775 ${hcfg.user} ${hcfg.group} -"
    ];

    sops.secrets."n100/protonvpn-wireguard-private-key" = { };
    sops.templates."n100/gluetun/.env" = {
      content = ''
        WIREGUARD_PRIVATE_KEY=${
          config.sops.placeholder."n100/protonvpn-wireguard-private-key"
        }
      '';
    };

    virtualisation.oci-containers.containers = {
      # https://github.com/qdm12/gluetun-wiki/blob/main/setup/advanced/control-server.md
      gluetun-soulseek = {
        image = "qmcgaw/gluetun";
        pull = "always";
        ports = [
          # For soulseek since the networking is going through this container
          "5030:6080"
        ];
        capabilities = { NET_ADMIN = true; };
        environment = {
          VPN_SERVICE_PROVIDER = "protonvpn";
          VPN_TYPE = "wireguard";
          SERVER_COUNTRIES = "Germany";
          PORT_FORWARD_ONLY = "on";
          VPN_PORT_FORWARDING = "on";
          HTTP_CONTROL_SERVER_AUTH_CONFIG_FILEPATH = "/gluetun/auth/config.toml";
        };
        volumes = [
          "${cfg.baseDir}/gluetun-auth-config.toml:/gluetun/auth/config.toml"
        ];
        environmentFiles = [ config.sops.templates."n100/gluetun/.env".path ];
        devices = [ "/dev/net/tun:/dev/net/tun" ];
      };
      nicotine-plus = {
        image = "ghcr.io/fletchto99/nicotine-plus-docker:latest";
        pull = "always";
        environment = {
          PUID = "${builtins.toString
            config.users.users."${config.homelab.user}".uid}";
          PGID = "${builtins.toString
            config.users.groups."${config.homelab.group}".gid}";
          TZ = "${config.time.timeZone}";
        };
        volumes = [
          "${cfg.baseDir}:/config"
          "${hcfg.media.libDir}/music:/data/shared"
          "${hcfg.media.torrentDir}/soulseek:/data/downloads"
          "${hcfg.media.torrentDir}/.soulseek_incomplete:/data/incomplete_downloads"
        ];
        extraOptions = [
          # For Docker Engine only, many modern gui apps need this to function as syscalls are unkown to Docker.
          "--security-opt=seccomp=unconfined"
          # This makes it share gluetun's network namespace:
          "--network=container:gluetun-soulseek"
        ];
        dependsOn = [ "gluetun-soulseek" ];
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
