{ config, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./stylix.nix

    ../common/core

    ../common/optional/base-gnome.nix
    ../common/optional/sound.nix
    ../common/optional/smb.nix
    ../common/optional/scanner.nix
    ../common/optional/sound.nix
    ../common/optional/gaming.nix
    ../common/optional/printing.nix
    ../common/optional/usb-waekup-disable.nix

    ../common/users/katerina.nix
  ];

  mySystems.smb = {
    enable = true;
    credentials = config.sops.secrets."anteater/smb-credentials".path;
  };

  mySystems.scanner = { enable = true; };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "anteater";

  hardware.usb.wakeupDisabled = [{
    vendor = "046d";
    product = "c548";
  }];
}
