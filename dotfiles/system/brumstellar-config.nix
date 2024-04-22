{ ... }:
{
  imports = [
    ./hardware/brumstellar.nix
    ./modules/base-configuration.nix
    ./modules/nvidia.nix
    ./modules/dualboot.nix
    ./modules/docker.nix
    ./modules/smb.nix
  ];

  services.ollama = {
    enable = true;
    acceleration = "cuda";
  };
}
