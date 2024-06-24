{ ... }:
{
  imports = [
    ./hardware/anteater.nix
    ./modules/base-configuration.nix
    ./modules/amdRX570.nix
    ./modules/smb.nix
  ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };
}
