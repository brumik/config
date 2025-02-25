{ config, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix

    ../common/core

    ../common/optional/base-gnome.nix
    ../common/optional/sound.nix
    ../common/optional/smb.nix
    ../common/optional/scanner.nix
    ../common/optional/sound.nix
    ../common/optional/stylix-default.nix
    ../common/optional/gaming.nix

    ../common/users/katerina.nix
  ];

  mySystems.smb = {
    enable = true;
    credentials = config.sops.secrets."anteater/smb-credentials".path;
  };

  mySystems.scanner = {
    enable = true;
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "anteater";

  # Styling
  stylix = {
    image = lib.mkForce ../assets/wallpapers/anteater-3360x2240.jpg;
  };
}
