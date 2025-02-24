{ lib, ... }:
{
  imports = [
    ./hardware/anteater.nix
    ./modules/base-configuration.nix
    ./modules/stylix-default.nix
    ./modules/sops.nix
    ./modules/hosts.nix
    # ./modules/nvidia.nix
    # ./modules/ollama.nix
  ];

  networking.hostName = "nixos-katerina";

  # Needed for the sops keys
  services.openssh = {
    enable = true;
  };

  networking.interfaces.wlp5s0.ipv4.addresses = [{
    address = "192.168.1.101";
    prefixLength = 32;
  }];


  users.users.root = {
    openssh.authorizedKeys.keys = [
      "${builtins.readFile ../../keys/id-brum.pub}"
    ];
  };

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
