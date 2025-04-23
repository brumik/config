{ ... }: {
  imports = [
    ./hardware-configuration.nix
    ../common/core

    ../common/optional/nvidia.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "sleeper"; # Define your hostname.

  services.ollama = {
    enable = true;
    acceleration = "cuda";
    host = "0.0.0.0";
    port = 11434;
    loadModels = [ "gemma3:27b" "deepseek-r1:32b" "mxbai-embed-large" ];
  };

  # AI Web UI testing
  services.open-webui = {
    enable = true;
    host = "0.0.0.0";
    port = 11111;
    environment = {
      OLLAMA_API_BASE_URL = "http://127.0.0.1:11434";
      # Disable authentication
      WEBUI_AUTH = "False";
    };
  };

  # Open firewall for ollama
  networking.firewall.allowedTCPPorts = [ 11434 11111 ];
}
