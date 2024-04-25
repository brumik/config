{ ... }:
{
  imports = [
    ./hardware/anteater.nix
    ./modules/base-configuration.nix
  ];

  services.ollama = {
    enable = true;
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };
}
