{ config, lib, pkgs, ... }:
let
  cfg = config.mySystems.smb;
  defaults = [
    "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s"
  ];
  credentials = [ "credentials=${cfg.credentials}" ];
  permissions = [
    "gid=${
      toString config.users.groups.smbusers.name
    },file_mode=0664,dir_mode=0775"
  ];
  options = defaults ++ credentials ++ permissions;
in {
  options.mySystems.smb = {
    enable = lib.mkEnableOption "SMB";

    users = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "The list of users added to the group of docker";
    };

    credentials = lib.mkOption {
      type = lib.types.path;
      description = "The path to the credentials file for SMB";
    };
  };

  config = lib.mkIf cfg.enable {
    users.groups.smbusers = { members = cfg.users; };

    environment.systemPackages = [ pkgs.cifs-utils ];
    fileSystems."/mnt/brumspace/share" = {
      device = "//192.168.1.2/share";
      fsType = "cifs";
      inherit options;
    };
    fileSystems."/mnt/brumspace/video" = {
      device = "//192.168.1.2/video";
      fsType = "cifs";
      inherit options;
    };
    fileSystems."/mnt/brumspace/home" = {
      device = "//192.168.1.2/home";
      fsType = "cifs";
      inherit options;
    };
  };
}
