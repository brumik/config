{ config, lib, ... }:
let
  cfg = config.homelab.media;
  hcfg = config.homelab;
in {
  imports = [
    ./gluetun.nix
    ./transmission.nix
    ./jellyfin.nix
    ./jellyseerr.nix
    ./prowlarr.nix
    ./lidarr.nix
    ./radarr.nix
    ./sonarr.nix
    ./recyclarr.nix
    ./bazarr.nix
    ./audiobookshelf.nix
    ./calibre.nix
  ];

  options.homelab.media = {
    enable = lib.mkEnableOption "media";

    baseDir = lib.mkOption {
      type = lib.types.path;
      default = "/media";
      description =
        "The absolute path where the service will store the important informations";
    };
    torrentDir = lib.mkOption {
      type = lib.types.path;
      default = "/media/torrents";
      description =
        "The absolute path where the service will store the important informations";
    };
    usenetDir = lib.mkOption {
      type = lib.types.path;
      default = "/media/usenet";
      description =
        "The absolute path where the service will store the important informations";
    };
    libDir = lib.mkOption {
      type = lib.types.path;
      default = "/media/library";
      description =
        "The absolute path where the service will store the important informations";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = lib.hasPrefix cfg.baseDir cfg.torrentDir;
        message = "Homelab Media torrentDir needs to be under baseDir.";
      }
      {
        assertion = lib.hasPrefix cfg.baseDir cfg.usenetDir;
        message = "Homelab Media usenetDir needs to be under baseDir.";
      }
      {
        assertion = lib.hasPrefix cfg.baseDir cfg.libDir;
        message = "Homelab Media libDir needs to be under baseDir.";
      }
    ];

    systemd.tmpfiles.rules = [
      "d ${cfg.baseDir} 0775 ${hcfg.user} ${hcfg.group} -"
      "d ${cfg.torrentDir} 0775 ${hcfg.user} ${hcfg.group} -"
      "d ${cfg.usenetDir} 0775 ${hcfg.user} ${hcfg.group} -"
      "d ${cfg.libDir} 0775 ${hcfg.user} ${hcfg.group} -"
    ];
  };
}
