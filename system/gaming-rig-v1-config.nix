{ ... }:
{
  imports = [
    ./hardware/gaming-rig-v1.nix
    ./modules/base-configuration.nix
    ./modules/stylix-everforest.nix
    ./modules/nvidia.nix
    ./modules/ollama.nix
  ];

  networking.hostName = "nixos-gaming-rig-v1";

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; 
  };

  # Enable Xbox accessories
  hardware.xone.enable = true;

  # Autologin the default user
  services.displayManager.autoLogin = {
    enable = true;
    user = "gamer";
  };
}
