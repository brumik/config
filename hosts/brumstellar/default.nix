{ pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./stylix.nix

    ../common/core
    ../common/optional/base-gnome.nix
    ../common/optional/sound.nix
    ../common/optional/docker.nix
    ../common/optional/scanner.nix
    ../common/optional/sound.nix
    ../common/optional/gaming.nix
    ../common/optional/printing.nix
    ../common/optional/usb-waekup-disable.nix
    ../common/optional/nfs.nix
    ../common/optional/appstores.nix

    ../common/optional/deployment-ssh.nix

    ../common/users/levente.nix
  ];

  mySystems = {
    docker.enable = true;
    scanner.enable = true;
    nfs.enable = true;
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "brumstellar";

  #############################################
  # Custom or temporary stuff                 #
  #############################################

  # Needed for the yubike UI
  services.pcscd = { enable = true; };

  # Trust the network to enable playing LAN games
  networking.firewall.trustedInterfaces = [ "wlp5s0" ];

  hardware.usb.wakeupDisabled = [{
    vendor = "046d";
    product = "c548";
  }];

  # Disable typing the password then using sudo
  # security.sudo.wheelNeedsPassword = false;

  programs.localsend = {
    enable = true;
    openFirewall = true;
  };

  # Quick fix for missing file picker in QT apps like Picard
  # https://github.com/NixOS/nixpkgs/issues/149812#issuecomment-3647060694
  environment.extraInit = ''
    export XDG_DATA_DIRS="$XDG_DATA_DIRS:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}"
  '';
}
