{ config, lib, pkgs, ... }:
let
  cfg = config.homelab.media.prowlarr;
  hcfg = config.homelab;
  baseDirDefaultVal = "/var/lib/prowlarr";
  dname = "${cfg.domain}.${hcfg.domain}";
in {
  options.homelab.media.prowlarr = {
    enable = lib.mkEnableOption "prowlarr";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "prowlarr";
      description = "The subdomain where the service will be served";
    };

    baseDir = lib.mkOption {
      type = lib.types.path;
      default = baseDirDefaultVal;
      description =
        "The absolute path where the service will store the important information";
    };
  };

  config = lib.mkIf (hcfg.enable && hcfg.media.enable && cfg.enable) {
    # TODO: Only avaiable after NixOS 25.11
    # services.prowlarr = {
    #   enable = true;
    #   dataDir = cfg.baseDir;
    #   server = {
    #     # https://wiki.servarr.com/prowlarr/environment-variables
    #     port = 9696;
    #   };
    # };

    systemd.services.prowlarr = {
      description = "prowlarr";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      environment.PROWLARR__SERVER__PORT = builtins.toString 9696;

      serviceConfig = {
        Type = "simple";
        DynamicUser = true;
        StateDirectory = "prowlarr";
        ExecStart =
          "${lib.getExe pkgs.prowlarr} -nobrowser -data=${baseDirDefaultVal}";
        Restart = "on-failure";
      };
    };

    # Helps resolving some cloudflare challenges for some of the
    # indexer websites. It is using a container since the nixpkgs unstable is outdated 
    virtualisation.oci-containers.containers.flaresolverr = {
      image = "ghcr.io/flaresolverr/flaresolverr:latest";
      pull = "always";
      environment = {
        LOG_LEVEL = "info";
        LOG_FILE = "none";
        LOG_HTML = "false";
        CAPTCHA_SOLVER = "none";
        TZ = "${config.time.timeZone}";
      };
      ports = [ "8191:8191" ];
    };

    systemd.tmpfiles.rules = lib.mkIf (cfg.baseDir != baseDirDefaultVal) [
      "d ${cfg.baseDir} 0755 root root -"
      "L ${baseDirDefaultVal} - - - - ${cfg.baseDir}"
    ];

    homelab.traefik.routes = [{
      host = cfg.domain;
      port = 9696;
    }];

    homelab.backup.stateDirs = [ cfg.baseDir ];

    homelab.homepage.arr = [{
      Prowlarr = {
        icon = "prowlarr.png";
        href = "https://${dname}";
        siteMonitor = "https://${dname}";
        description = "Indexer";
      };
    }];
  };
}
