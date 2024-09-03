{ ... }:
{
  imports = [
    ./hardware/n100.nix
    ./modules/base-configuration.nix
    ./modules/docker.nix
    ./modules/smb.nix
    ./modules/monitorcontroll.nix
  ];
  
  networking.hostName = "nixos-n100"; # Define your hostname.
  
}
