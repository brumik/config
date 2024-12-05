{ pkgs, ... }:
{
  imports = [
    ./hardware/carol.nix
    ./modules/base-configuration.nix
    ./modules/stylix-everforest.nix
  ];

  networking.hostName = "nixos-carol";
}
