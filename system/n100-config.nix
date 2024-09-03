{ ... }:
{
  imports = [
    ./hardware/n100.nix
    ./modules/base-configuration.nix
  ];
  
  networking.hostName = "nixos-n100"; # Define your hostname.
  
}
