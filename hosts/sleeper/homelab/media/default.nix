{ config, lib, ... }:
let
  cfg = config.homelab.media;
  hcfg = config.homelab;
in {
  imports = [
    ./transmission.nix
    ./soulseek.nix
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
        "The absolute path where the service will store the important information";
    };
    torrentDir = lib.mkOption {
      type = lib.types.path;
      default = "/media/torrents";
      description =
        "The absolute path where the service will store the important information";
    };
    libDir = lib.mkOption {
      type = lib.types.path;
      default = "/media/library";
      description =
        "The absolute path where the service will store the important information";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = lib.hasPrefix cfg.baseDir cfg.torrentDir;
        message = "Homelab Media torrentDir needs to be under baseDir.";
      }
      {
        assertion = lib.hasPrefix cfg.baseDir cfg.libDir;
        message = "Homelab Media libDir needs to be under baseDir.";
      }
    ];

    systemd.tmpfiles.rules = [
      "d ${cfg.baseDir} 0775 ${hcfg.user} ${hcfg.group} -"
      "d ${cfg.torrentDir} 0775 ${hcfg.user} ${hcfg.group} -"
      "d ${cfg.libDir} 0775 ${hcfg.user} ${hcfg.group} -"
    ];
  };
}
