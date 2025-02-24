{ username }: { config, pkgs, ... }:
let
  options = ["x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s,credentials=${config.sops.secrets.smb-credentials.path},gid=${toString config.users.groups.smbusers.name},file_mode=0664,dir_mode=0775"];

## README 
# This config depends on: server ip address for smb, uid of user and gid and user home path
# Furthermore it expects on the given path the samba credentials.
# The credentials should be provided by Bitwarden script.
in {
  users.groups.smbusers = {};
  users.users."${username}".extraGroups = [ "smbusers" ];

  # TODO Mount it to /mnt
  environment.systemPackages = [ pkgs.cifs-utils ];
  fileSystems."/home/${username}/brumspace/share" = {
    device = "//192.168.1.2/share";
    fsType = "cifs";
    inherit options; 
  };
  fileSystems."/home/${username}/brumspace/video" = {
    device = "//192.168.1.2/video";
    fsType = "cifs";
    inherit options; 
  };
  fileSystems."/home/${username}/brumspace/home" = {
    device = "//192.168.1.2/home";
    fsType = "cifs";
    inherit options; 
  };
}
