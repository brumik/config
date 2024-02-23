{ ... }:
{
  imports = [
    ./hardware/brumstellar.nix
    ./modules/base-configuration.nix
    ./modules/nvidia.nix
    ./modules/dualboot.nix
    ./modules/tailscale.nix
    ./modules/docker.nix
    ./modules/ollama.nix

    ./users/levente.nix
  ];
}
