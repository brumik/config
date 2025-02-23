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

  # Needed for the sops keys
  services.openssh.enable = true;

  sops = {

    defaultSopsFile = ../secrets.yaml;
    validateSopsFiles = false;

    age = {
      sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      keyFile = "/var/lib/sops-nix/key.txt";
      generateKey = true;
    };

    secrets = {
      levente-smb-credentials = { };
      work-smb-credentials = { };
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
