{ config, ... }: {
  imports = [
    ./hardware-configuration.nix

    ../common/core

    ../common/optional/base-gnome.nix
    ../common/optional/sound.nix
    ../common/optional/docker.nix
    ../common/optional/smb.nix
    ../common/optional/nvidia.nix
    ../common/optional/ollama.nix
    ../common/optional/scanner.nix
    ../common/optional/sound.nix
    ../common/optional/stylix-everforest.nix
    ../common/optional/gaming.nix

    ../common/users/levente.nix
    ../common/users/work.nix
  ];

  mySystems.smb = {
    enable = true;
    credentials = config.sops.secrets."brum/smb-credentials".path;
  };

  mySystems.docker = {
    enable = true;
  };

  mySystems.scanner = {
    enable = true;
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "brumstellar";

  #############################################
  # Custom or temporary stuff                 #
  #############################################

  # Needed for the yubike UI
  services.pcscd = { enable = true; };
  virtualisation.vmware.host.enable = true;
}
