{ config, lib, ... }:
let
  cfg = config.homelab.media.picard;
  hcfg = config.homelab;
  dname = "${cfg.domain}.${hcfg.domain}";
in {
  options.homelab.media.picard = {
    enable = lib.mkEnableOption "picard";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "picard";
      description = "The subdomain where the service will be served";
    };

    baseDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/oci-picard";
      description =
        "The absolute path where the service will store the important informations";
    };
  };

  config = lib.mkIf (hcfg.enable && hcfg.media.enable && cfg.enable) {
    systemd.tmpfiles.rules = [
      "d ${cfg.baseDir} ${hcfg.user} ${hcfg.group} -"
      "d ${hcfg.media.libDir}/music 0775 ${hcfg.user} ${hcfg.group} -"
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
      musicbrainz-picard = {
        image = "mikenye/picard";
        pull = "always";
        ports = [ "5800:5800" ];
        environment = {
          USER_ID = "${builtins.toString
            config.users.users."${config.homelab.user}".uid}";
          GROUP_ID = "${builtins.toString
            config.users.groups."${config.homelab.group}".gid}";
          TZ = "${config.time.timeZone}";
        };
        volumes = [
          "${cfg.baseDir}:/config"
          "${hcfg.media.libDir}/music:/storage"
        ];
      };
    };

    homelab.traefik.routes = [{
      host = cfg.domain;
      port = 5800;
    }];

    homelab.backup.stateDirs = [ cfg.baseDir ];

    homelab.homepage.arr = [{
      Soulseek = {
        icon = "musicbrainz.png";
        href = "https://${dname}";
        siteMonitor = "https://${dname}";
        description = "Musicbrainz Picard Audio organizer";
      };
    }];
  };
}
