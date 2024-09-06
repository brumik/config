{ ... }:
{
  imports = [
    ./hardware/n100.nix
    ./modules/base-configuration.nix
    ./modules/stylix-default.nix
  ];
  
  networking.hostName = "nixos-n100"; # Define your hostname.
  
}
