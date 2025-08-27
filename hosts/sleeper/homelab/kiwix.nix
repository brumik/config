{ config, lib, ... }:
let
  cfg = config.homelab.kiwix;
  dname = "${cfg.domain}.${config.homelab.domain}";
in {
  options.homelab.kiwix = {
    enable = lib.mkEnableOption "kiwix";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "wiki";
      description = "The subdomain where the service will be served";
    };

    zimDir = lib.mkOption {
      type = lib.types.path;
      default = "/media/Wikipedias";
      description = "The absolute path where the wikipedia zim files are stored";
    };
  };

  config = lib.mkIf cfg.enable {

    virtualisation.oci-containers.containers.kiwix = {
      image = "ghcr.io/kiwix/kiwix-serve:latest";
      pull = "always";
      ports = [ "10004:8080" ];
      cmd = [ "*.zim" ];
      volumes = [
        "${cfg.zimDir}:/data"
      ];
    };

    homelab.traefik.routes = [{
      host = cfg.domain;
      port = 10004;
    }];

    homelab.authelia.exposedDomains = [ dname ];

    homelab.homepage.app = [{
      Kiwix = {
        icon = "kiwix.png";
        href = "https://${dname}";
        siteMonitor = "https://${dname}";
        description = "Local Wikipedia";
      };
    }];
  };
}
