{ ... }: {
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
    ./homelab
    ./levente.nix

    ../common/core
    ../common/optional/deployment-ssh.nix
  ];

  networking.hostName = "sleeper"; # Define your hostname.

  # Generated from machine id, ensures we import zfs on correct machine
  # WARNING: changing this number will cause ZFS to fail import and keep hanging on boot
  networking.hostId = "20c133b6"; # head -c 8 /etc/machine-id

  # Including setting up ZFS boot
  mySystems.disks = {
    enable = true;
    # If changes how MANY disks are here, update smartd
    rootDisk1 = "/dev/disk/by-id/nvme-KINGSTON_SKC3000S512G_50026B7686F84D4B";
    rootDisk2 = "/dev/disk/by-id/nvme-KINGSTON_SKC3000S512G_50026B7383A70C89";
    dataDisk1 = "/dev/disk/by-id/wwn-0x5000c500e63c5e5b";
    dataDisk2 = "/dev/disk/by-id/wwn-0x5000c500c7482d01";
    dataSpare = "/dev/disk/by-id/wwn-0x5000c500e63bab3c";
    dataCache = "/dev/disk/by-id/ata-ADATA_SU650_2O432LAAK4HD";
    rootReservation = "70G"; # 10+% of total size
  };

  # Enables the APC UPS daemon. By default turns off if battery:
  # is under 50% or min time left is under 5 min
  services.apcupsd = {
    enable = true;
    configText = ''
      UPSTYPE usb
      NISIP 127.0.0.1
      BATTERYLEVEL 50
      MINUTES 5
    '';
  };

  homelab = {
    enable = true;
    domain = "berky.me";
    serverIP = "192.168.2.129";
    gateway = "192.168.2.1";
    subnet = "192.168.0.0/16"; # include all potential subnets


    monitoring.enable = true;

    # Self config
    zfs.enable = true;
    smart.enable = true;
    email.enable = true;
    power.enable = true;
    nvidia = {
      enable = true;
      cachesEnabled = true; # we have nvidia community cache
      power = {
        enable = true;
        limit = 280;
      };
    };
    backup = {
      enable = true;
      # Add extra state dirs
      stateDirs = [
        "/backup"
      ];
    };

    # Infra
    tailscale = {
      enable = true;
      serverIP = "100.93.65.122";
      trustedIPs = [
        "100.123.170.119" # angeli-t490
        "100.86.176.73" # ipad-air-gen-4
        "100.79.31.69" # nothing-a142
        "100.123.113.7" # google-pixel-7-1
      ];
    };
    cache.enable = true;
    auto-update = {
      enable = true;
      hosts = [ "brumstellar" "anteater" "sleeper" "gamingrig" "nixos-live" ];
    };
    # ddclient.enable = true; # Not needed since the vpn trough VPS
    lldap.enable = true;
    authelia.enable = true;
    traefik.enable = true;
    adguardhome.enable = true;
    glances.enable = true;

    # Mission critical
    vaultwarden = {
      enable = true;
      backupDir = "/persist/vaultwarden-backup";
    };
    nextcloud.enable = true;
    immich = {
      enable = true;
      baseDir = "/photos/immich";
    };
    home-assistant = {
      enable = true;
      image = "/persist/haos.qcow2";
      imageBackup = "/backup/haos.qcow2";
    };

    # Media
    media = {
      enable = true;
      # Builders
      # Temp disabled
      # transmission.enable = true;
      # prowlarr.enable = true;
      # radarr.enable = true;
      # sonarr.enable = true;
      # recyclarr.enable = true;
      # bazarr.enable = true;

      # This i don't like
      # lidarr.enable = true;

      # soulseek.enable = true;
      # Consumers
      jellyfin.enable = true;
      # jellyseerr.enable = true;
      audiobookshelf.enable = true;
      calibre.enable = true;
    };
    freshrss.enable = true;
    # kiwix.enable = true;

    # Rest
    homepage.enable = true;
    radicale.enable = true;
    mealie.enable = true;
    ollama.enable = true;
    open-webui = {
      enable = true;
      baseDir = "/persist/oci-open-webui";
    };
    stirling-pdf.enable = true;
    wishlist.enable = true;
    nfs.enable = true;
    printing.enable = true;

    # TEMP
    # minecraft.enable = true;
  };
}
