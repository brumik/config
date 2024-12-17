{ lib, ... }:
{
  imports = [
    ./hardware/anteater.nix
    ./modules/base-configuration.nix
    ./modules/stylix-default.nix
    ./modules/nvidia.nix
  ];

  networking.hostName = "nixos-katerina";

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; 
  };

  # Styling
  stylix = {
    image = lib.mkForce ../wallpapers/anteater-3360x2240.jpg;
  };
}
