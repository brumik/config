{ config, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./stylix.nix

    ../common/core

    ../common/optional/base-gnome.nix
    ../common/optional/sound.nix
    ../common/optional/docker.nix
    ../common/optional/smb.nix
    ../common/optional/nvidia.nix
    ../common/optional/ollama.nix
    ../common/optional/scanner.nix
    ../common/optional/sound.nix
    ../common/optional/gaming.nix

    ../common/users/levente.nix
    ../common/users/work.nix

    # ./vm.nix
  ];

  mySystems.smb = {
    enable = true;
    credentials = config.sops.secrets."brum/smb-credentials".path;
  };

  mySystems.docker = { enable = true; };

  mySystems.scanner = { enable = true; };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "brumstellar";

  #############################################
  # Custom or temporary stuff                 #
  #############################################

  # Needed for the yubike UI
  services.pcscd = { enable = true; };

  # AI Web UI testing
  services.open-webui = {
    enable = true;
    package = pkgs.unstable.open-webui;
    port = 11111;
    environment = {
      OLLAMA_API_BASE_URL = "http://127.0.0.1:11434";
      # Disable authentication
      WEBUI_AUTH = "False";
    };
  };
}
