{ ... }:
{
  imports = [
    ./hardware/anteater.nix
    ./modules/base-configuration.nix
    ./modules/steam.nix
    # ./modules/tailscale.nix

    ./users/katerina.nix
  ];

  services.ollama = {
    enable = true;
  };
}
