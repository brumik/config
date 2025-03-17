{ config, pkgs, ... }:
let
  options = ["x-systemd.automount,noauto,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s,credentials=${config.sops.secrets."n100/smb-credentials".path},gid=${toString config.users.groups.${config.homelab.group}.gid},file_mode=0664,dir_mode=0775"];

in {
  sops.secrets."n100/smb-credentials" = {};

  environment.systemPackages = [ pkgs.cifs-utils ];
  fileSystems."/mnt/video" = {
    device = "//${config.homelab.smbServerIP}/video";
    fsType = "cifs";
    inherit options; 
  };
  fileSystems."/mnt/homes" = {
    device = "//${config.homelab.smbServerIP}/homes";
    fsType = "cifs";
    inherit options; 
  };
  # TODO Move to backup and localize, no reason all apps need to access this
  fileSystems."/mnt/share" = {
    device = "//${config.homelab.smbServerIP}/share";
    fsType = "cifs";
    inherit options; 
  };
}
