{ ... }: {
  imports = [
    ./hardware-configuration.nix
    ../common/core

    ../common/optional/nvidia.nix
    ../common/optional/ollama.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "sleeper"; # Define your hostname.

  # Open firewall for ollama
  networking.firewall.allowedTCPPorts = [ 11434 ];
}
