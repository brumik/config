{ ... }:
{
  imports = [
    ./hardware/gaming-rig-v1.nix
    ./modules/base-configuration.nix
    ./modules/stylix-everforest.nix
    ./modules/nvidia.nix
    ./modules/ollama.nix
    ./modules/gaming.nix
  ];

  networking.hostName = "nixos-gaming-rig-v1";

  # Autologin the default user
  services.displayManager.autoLogin = {
    enable = true;
    user = "gamer";
  };
}
