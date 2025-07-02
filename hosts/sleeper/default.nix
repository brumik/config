{ pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./disko.nix

    ./email.nix
    ./nixos-updater.nix

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

  services.sanoid = {
    enable = true;
    # every six hours
    interval = "*-*-* 00,06,12,18:00:00";
    templates.backup = {
      hourly = 12;
      daily = 30;
      monthly = 4;
      yearly = 12;
      autoprune = true;
      autosnap = true;
    };

    datasets."dpool/backup" = { useTemplate = [ "backup" ]; };
    datasets."dpool/media" = { useTemplate = [ "backup" ]; };
    datasets."dpool/photos" = { useTemplate = [ "backup" ]; };
    datasets."rpool/safe" = { useTemplate = [ "backup" ]; };
  };

  services.zfs = {
    # The autoSnapshot is not configurable how many times run
    # this means that it wakes up all disks every 5 min, spinning
    # up the disks constantly.

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

    cache.enable = true;
    power.enable = true;

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
      imageBackup = "/backup/haos.qcow2";
    };
  };
}
