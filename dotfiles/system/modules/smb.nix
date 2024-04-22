{ pkgs, username, ... }:

## README 
# This config depends on: server ip address for smb, uid of user and gid and user home path
# Furthermore it expects on the given path the samba credentials.
# The credentials should be provided by Bitwarden script.
{
  environment.systemPackages = [ pkgs.cifs-utils ];
  fileSystems."/mnt/video" = {
    device = "//192.168.1.2/video";
    fsType = "cifs";
    options = let
      # this line prevents hanging on network split
      automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";

    in ["${automount_opts},credentials=/home/levente/smb-secrets,uid=1000,gid=100"];
  };
}
