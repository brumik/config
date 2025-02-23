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

  # fileSystems."/mnt/test" = {
  #   device = "192.168.1.2:/volume1/video";
  #   fsType = "nfs";
  #   # options = [];
  # };

  security.pam.services = {
    login.u2fAuth = false;
    sudo.u2fAuth = true;
  };
}
