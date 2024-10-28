{ username }: { config, pkgs, ... }:
let
  options = ["x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s,credentials=/home/${username}/smb-secrets,uid=${toString config.users.users."${username}".uid}"];

## README 
# This config depends on: server ip address for smb, uid of user and gid and user home path
# Furthermore it expects on the given path the samba credentials.
# The credentials should be provided by Bitwarden script.
in {
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
