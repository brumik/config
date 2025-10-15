{ ... }: {
  imports = [
    ./hardware-configuration.nix
    ./stylix.nix

    ../common/core

    ../common/optional/base-gnome.nix
    ../common/optional/sound.nix
    ../common/optional/scanner.nix
    ../common/optional/sound.nix
    ../common/optional/gaming.nix
    ../common/optional/printing.nix
    ../common/optional/usb-waekup-disable.nix
    ../common/optional/nfs.nix

    ../common/users/katerina.nix
  ];

  mySystems = {
    scanner.enable = true;
    nfs.enable = true;
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "anteater";

  # Trust the network to enable playing LAN games
  networking.firewall.trustedInterfaces = [ "wlp5s0" ];

  hardware.usb.wakeupDisabled = [{
    vendor = "046d";
    product = "c548";
  }];

  # Enable appimage support for some apps
  programs.appimage.enable = true;
  programs.appimage.binfmt = true;

  # Enable clipboard manager, needs system service
  programs.gpaste.enable = true;
}
