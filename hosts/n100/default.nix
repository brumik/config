{ config, ... }: 
let
  username = "n100";
in {
  imports = [
    ./hardware-configuration.nix

    ../common/core

    ../common/optional/homelab
    ../common/optional/docker.nix
    ../common/optional/smb.nix
  ];

  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
  };

  networking.hostName = "n100"; # Define your hostname.

  # Temporary user copy
  users.users."${username}" = {
    uid = 1000;
    isNormalUser = true;
    initialPassword = "passwd";
    description = "Brum";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  mySystems.docker = {
    enable = true;
    users = [ "n100" ];
  };

  mySystems.smb = {
    enable = true;
    credentials = config.sops.secrets."n100/smb-credentials".path;
    users = [ "n100" ];
  };

  home-manager.users.${username} = import ../../home/${username} { inherit username; };
  # End temporary user copy

  # Services trying
  homelab = {
    enable = true;
    domain = "berky.me";
    serverIP = "192.168.1.127";
    gateway = "192.168.1.1";
    tailscale.enable = true;

    vaultwarden.enable = true;
    traefik.enable = true;
    adguardhome.enable = true;
    ddclient.enable = true;
    jellyfin.enable = true;
    radicale.enable = true;
    mealie.enable = true;
    languagetool.enable = true;
    freshrss.enable = true;

    # TODO This might be required by other services so need to add there?
    lldap.enable = true;
    # Enable backup
    backup.enable = true;
    # Set up the new backup to back up the docker isntances too
    backup.stateDirs = [
      "/home/n100/docker"
    ];
  };
}
