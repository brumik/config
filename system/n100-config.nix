{ ... }: {
  imports = [
    ./hardware/n100.nix
    ./modules/base-configuration.nix
    # ./modules/stylix-default.nix
    ./modules/stylix-everforest.nix
  ];

  networking.hostName = "nixos-n100"; # Define your hostname.

  # Server preparation
  # ===========================

  # Enable binding on the 80 and 443 port for docker
  boot.kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = 0;
}
