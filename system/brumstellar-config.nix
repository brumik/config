{ lib, ... }:
{
  imports = [
    ./hardware/brumstellar.nix
    ./modules/base-configuration.nix
    ./modules/stylix-everforest.nix
  ];

  networking.hostName = "nixos-brumstellar";
}
