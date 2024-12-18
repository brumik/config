{ ... }:
{
  imports = [
    ./hardware/upgrader.nix
    ./modules/base-configuration.nix
    ./modules/stylix-everforest.nix
  ];

  networking.hostName = "nixos-upgrader";
}
