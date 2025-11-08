{ config, lib, ... }:
let
  cfg = config.mySystems.nfs;
  share = config.globals.users.share;
  options = [
    "nfsvers=4.2"
    "x-systemd.automount"
    "noauto"
    "x-systemd.idle-timeout=60"
    "x-systemd.device-timeout=5s"
    "x-systemd.mount-timeout=5s"
  ];
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

    users.groups.${share.gname} = {
      gid = share.gid;
      members = cfg.users;
    };

    fileSystems."/mnt/media" = {
      device = "sleeper.berky.me:/media";
      fsType = "nfs";
      options = options;
    };

    fileSystems."/mnt/backup" = {
      device = "sleeper.berky.me:/backup";
      fsType = "nfs";
      options = options;
    };
  };
}
