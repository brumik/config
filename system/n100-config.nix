{ ... }:
{
  imports = [
    ./hardware/n100.nix
    ./modules/base-configuration.nix
    # ./modules/stylix-default.nix
    ./modules/stylix-everforest.nix
  ];
  
  networking.hostName = "nixos-n100"; # Define your hostname.
  
}
