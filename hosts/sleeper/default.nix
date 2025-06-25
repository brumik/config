{ pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./disko.nix

    ./email.nix

    ../common/core
    ../common/optional/homelab
  ];

  networking.hostName = "sleeper"; # Define your hostname.

  # Generated from machine id, ensures we import zfs on correct machine
  # WARNING: changing this number will cause ZFS to fail import and keep hanging on boot
  networking.hostId = "20c133b6"; # head -c 8 /etc/machine-id

  # Including setting up ZFS, impermanence and boot
  mySystems.disks = {
    enable = true;
    rootDisk1 = "/dev/disk/by-id/nvme-KINGSTON_SKC3000S512G_50026B7686F84D4B";
    rootDisk2 = "/dev/disk/by-id/nvme-KINGSTON_SKC3000S512G_50026B7383A70C89";
    dataDisk1 = "/dev/disk/by-id/wwn-0x5000c500c8af03ce";
    # dataDisk2 = "/dev/disk/by-id/wwn-0x5000c500c7482d01";
    rootReservation = "70G"; # 10+% of total size
  };

  environment.systemPackages = [ pkgs.tmux ];

  # TODO: Jellyfin, Calibre, Audiobookshelf uses this path to reach the media
  # This is because of migration from smb share
  fileSystems."/mnt/video" = {
    device = "/media";
    options = [ "bind" ];
  };

  services.zfs = {
    # The default keeps a lot of snapshots starting with
    # every 15min for the last hour
    # and ending with 1 for each month for the last year
    autoSnapshot.enable = true;

    # Try to scrub and repair data every month once
    autoScrub.enable = true;

    # Run weekly trims 
    trim.enable = true;
  };

  homelab = {
    enable = true;
    domain = "berky.me";
    serverIP = "192.168.1.129";
    gateway = "192.168.1.1";
    nvidia.enable = true;
    tailscale.enable = true;
    authelia.enable = true;
    traefik.enable = true;

    homepage.enable = true;

    vaultwarden.enable = true;
    adguardhome.enable = true;
    ddclient.enable = true;
    jellyfin.enable = true;
    radicale.enable = true;
    mealie.enable = true;
    freshrss.enable = true;
    audiobookshelf.enable = true;
    webdav.enable = true;
    calibre.enable = true;
    immich = {
      enable = true;
      baseDir = "/photos/immich";
    };
    lldap.enable = true;
    backup = {
      enable = true;
      # Add extra state dirs
      stateDirs = [ "/backup" ];
    };
    ollama = {
      enable = true;
      loadModels = [ "gemma3:12b" "devstral:24b" "mxbai-embed-large" ];
    };
    open-webui.enable = true;
    nextcloud.enable = true;
    timetagger.enable = true;

    home-assistant = {
      enable = true;
      image = "/var/lib/haos.qcow2";
    };
  };
}
