{ config, pkgs, ... }:
let
  options = [
    "credentials=${config.sops.secrets."n100/smb-credentials".path}"
    "gid=${toString config.users.groups.${config.homelab.group}.gid}"
    "uid=${toString config.users.users.${config.homelab.user}.uid}"
    "file_mode=0774"
    "dir_mode=0775"
  ];
  cfg = config.homelab;
in {
  sops.secrets."n100/smb-credentials" = { };

  environment.systemPackages = [ pkgs.cifs-utils ];
  fileSystems."/mnt/video" = {
    device = "//${cfg.smbServerIP}/video";
    fsType = "cifs";
    inherit options;
  };
  fileSystems."/mnt/photo" = {
    device = "//${cfg.smbServerIP}/photo";
    fsType = "cifs";
    inherit options;
  };
  fileSystems."/mnt/homes" = {
    device = "//${cfg.smbServerIP}/homes";
    fsType = "cifs";
    inherit options;
  };
  # TODO Move to backup and localize, no reason all apps need to access this
  fileSystems."/mnt/share" = {
    device = "//${cfg.smbServerIP}/share";
    fsType = "cifs";
    inherit options;
  };

  # It has to have same gid and uid on synology and here. 
  # Unfortunatelly synology has no direct controll of ids
  # # NFS mount - will converst all of them
  # fileSystems."/mnt/shared-nfs" = {
  #   device = "${cfg.smbServerIP}:/volume1/share";
  #   fsType = "nfs";
  #   options = [ "nfsvers=4.0" "x-systemd.automount" "noauto" ];
  # };
  # # optional, but ensures rpc-statsd is running for on demand mounting
  # boot.supportedFilesystems = [ "nfs" ];
}
