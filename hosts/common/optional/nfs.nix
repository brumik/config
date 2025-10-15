{ config, lib, ... }:
let
  cfg = config.mySystems.nfs;
  share = config.globals.users.share;
in {
  options.mySystems.nfs = {
    enable = lib.mkEnableOption "nfs";

    users = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "The list of users added to the group of share";
    };
  };

  config = lib.mkIf cfg.enable {
    boot.supportedFilesystems = [ "nfs" ];

    users.groups.${share.gname} = { gid = share.gid; };
    users.groups.docker.members = cfg.users;

    fileSystems."/mnt/media" = {
      device = "sleeper.berky.me:/media";
      fsType = "nfs";
      options = [ "nfsvers=4.2" "x-systemd.automount" "noauto" ];
    };

    fileSystems."/mnt/share" = {
      device = "sleeper.berky.me:/share";
      fsType = "nfs";
      options = [ "nfsvers=4.2" "x-systemd.automount" "noauto" ];
    };
  };
}
