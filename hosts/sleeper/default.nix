{ ... }: {
  imports = [
    ./hardware-configuration.nix
    ./disko.nix

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
    dataDisk1 = "/dev/disk/by-id/ata-ST31000528AS_6VPD01MX";
    rootReservation = "70G"; # 10+% of total size
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
    backup.enable = true;
    ollama.enable = false;
    open-webui.enable = false;
    nextcloud.enable = true;

    home-assistant = {
      enable = true;
      image = "/var/lib/haos.qcow2";
    };
  };
}
