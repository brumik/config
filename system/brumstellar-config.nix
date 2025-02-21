{ ... }:
{
  imports = [
    ./hardware/brumstellar.nix
    ./modules/base-configuration.nix
    ./modules/stylix-everforest.nix
    ./modules/nvidia.nix
    ./modules/ollama.nix
    # ./modules/hyprland.nix
  ];

  networking.hostName = "nixos-brumstellar";
  virtualisation.vmware.host.enable = true;
  security.pam.services = {
    login.u2fAuth = false;
    sudo.u2fAuth = true;
  };
}
