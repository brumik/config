{ ... }: {
  boot.supportedFilesystems = [ "nfs" ];

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
}
