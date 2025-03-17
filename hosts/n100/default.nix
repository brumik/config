{ ... }: {
  imports = [
    ./hardware-configuration.nix
    ../common/core
    ../common/optional/homelab
  ];

  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
  };

  networking.hostName = "n100"; # Define your hostname.

  # Services trying
  homelab = {
    enable = true;
    domain = "berky.me";
    serverIP = "192.168.1.127";
    gateway = "192.168.1.1";
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
    languagetool.enable = true;
    freshrss.enable = true;
    audiobookshelf.enable = true;
    webdav.enable = true;
    calibre.enable = true;

    # TODO This might be required by other services so need to add there?
    lldap.enable = true;
    # Enable backup
    backup.enable = true;
    # Set up the new backup to back up the docker isntances too
    backup.stateDirs = [ "/home/n100/docker" ];
  };
}
