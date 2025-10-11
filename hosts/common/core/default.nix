{ ... }:
{
  imports = [
    ./auto-update.nix
    ./base.nix
    ./ssh.nix
    ./sops.nix
    ./networking.nix
    ./globals.nix
  ];
}
