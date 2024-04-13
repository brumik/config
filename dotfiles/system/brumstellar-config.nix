{ ... }:
{
  imports = [
    ./hardware/brumstellar.nix
    ./modules/base-configuration.nix
    ./modules/nvidia.nix
    ./modules/dualboot.nix
    ./modules/tailscale.nix
    ./modules/docker-nvidia.nix
    ./modules/ollama.nix
    ./modules/smb.nix
    ./modules/protonvpn.nix

    ./users/levente.nix
  ];
}
