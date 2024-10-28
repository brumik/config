{ ... }: {
  imports = [
    ./hardware/n100.nix
    ./modules/base-configuration.nix
    # ./modules/stylix-default.nix
    ./modules/stylix-everforest.nix
  ];

  boot.kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = 0;
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  networking.hostName = "nixos-n100"; # Define your hostname.
}
