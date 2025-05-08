{ ... }: {
  imports = [
    # hardware is generated on the host
    ../common/core/ssh.nix
    ../common/core/sops.nix
  ];
  networking.hostName = "nixos-live";
}
