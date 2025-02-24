{ ... }:
{
  imports = [
    ./hardware/brumstellar.nix
    ./modules/base-configuration.nix
    ./modules/stylix-everforest.nix
    ./modules/nvidia.nix
    ./modules/ollama.nix
    ./modules/sops.nix
    # ./modules/hyprland.nix
  ];

  networking.hostName = "nixos-brumstellar";
  virtualisation.vmware.host.enable = true;

  # Needed for the sops keys
  services.openssh = {
    enable = true;
      knownHosts = {
        "github/ed25519" = {
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
          hostNames = [ "github.com" ];
        };
        "berky.me/ed25519" = {
          publicKey = builtins.readFile ../keys/id-n100.pub;
          hostNames = [ "berky.me" ];
        };
      };
  };


  # fileSystems."/mnt/test" = {
  #   device = "192.168.1.2:/volume1/video";
  #   fsType = "nfs";
  #   # options = [];
  # };

  # security.pam.services = {
  #   login.u2fAuth = false;
  #   sudo.u2fAuth = true;
  # };
}
