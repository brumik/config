{ pkgs, username, brumspaceHome, ... }:
let
  options = ["x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s,credentials=/home/${username}/smb-secrets,uid=1000,gid=100"];

## README 
# This config depends on: server ip address for smb, uid of user and gid and user home path
# Furthermore it expects on the given path the samba credentials.
# The credentials should be provided by Bitwarden script.
in {
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
    device = "//192.168.1.2/homes/${brumspaceHome}";
    fsType = "cifs";
    inherit options; 
  };
}
