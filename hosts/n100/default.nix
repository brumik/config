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
    # Only place I used was obsidian but the plugin cannot support some 
    # security features defined in Traefik, so disabling for now
    languagetool.enable = false;

    freshrss.enable = true;
    audiobookshelf.enable = true;
    webdav.enable = true;
    calibre.enable = true;
    immich.enable = true;

    # TODO This might be required by other services so need to add there?
    lldap.enable = true;
    backup.enable = true;
  };
}
