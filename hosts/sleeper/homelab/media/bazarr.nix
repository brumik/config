{ config, lib, ... }:
let
  cfg = config.homelab.media.bazarr;
  hcfg = config.homelab;
  baseDirDefaultVal = "/var/lib/bazarr";
  dname = "${cfg.domain}.${hcfg.domain}";
in {
  options.homelab.media.bazarr = {
    enable = lib.mkEnableOption "bazarr";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "bazarr";
      description = "The subdomain where the service will be served";
    };

    baseDir = lib.mkOption {
      type = lib.types.path;
      default = baseDirDefaultVal;
      description =
        "The absolute path where the service will store the important informations";
    };
  };

  config = lib.mkIf (hcfg.enable && hcfg.media.enable && cfg.enable) {
    services.bazarr = {
      enable = true;
      user = hcfg.user;
      group = hcfg.group;
      listenPort = 6767;
      # TODO: only after 25.11 
      # dataDir = cfg.baseDir;
    };

    systemd.tmpfiles.rules = lib.mkIf (cfg.baseDir != baseDirDefaultVal) [
      "d ${cfg.baseDir} 0755 root root -"
      "L ${baseDirDefaultVal} - - - - ${cfg.baseDir}"
    ];

    homelab.traefik.routes = [{
      host = cfg.domain;
      port = 6767;
    }];

    homelab.backup.stateDirs = [ cfg.baseDir ];

    homelab.homepage.arr = [{
      Bazarr = {
        icon = "bazarr.png";
        href = "https://${dname}";
        siteMonitor = "https://${dname}";
        description = "Subtitles search and fetcher";
      };
    }];
  };
}
