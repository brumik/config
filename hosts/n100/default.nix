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
    immich.enable = true;
    # TODO switch back on when using the AIO container instead of nix package
    # https://github.com/nextcloud/all-in-one/blob/main/reverse-proxy.md
    nextcloud.enable = false;

    # TODO This might be required by other services so need to add there?
    lldap.enable = true;
    # Enable backup
    backup.enable = true;
  };
}
