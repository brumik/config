{ config, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./stylix.nix

    ../common/core
    ../common/optional/base-gnome.nix
    ../common/optional/sound.nix
    ../common/optional/docker.nix
    ../common/optional/scanner.nix
    ../common/optional/sound.nix
    ../common/optional/gaming.nix
    ../common/optional/printing.nix

    ../common/users/levente.nix
    ../common/users/work.nix
  ];

  # The root of this pc should be able to log in to the root of every other PC
  sops.secrets = { "private-keys/id-deploy" = { }; };

  programs.ssh.extraConfig = ''
    Host *.berky.me
        IdentityFile ${config.sops.secrets."private-keys/id-deploy".path}
        IdentitiesOnly yes
  '';

  mySystems.docker = { enable = true; };
  mySystems.scanner = { enable = true; };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "brumstellar";

  #############################################
  # Custom or temporary stuff                 #
  #############################################

  # Needed for the yubike UI
  services.pcscd = { enable = true; };

  system.autoUpgrade = {
    enable = true;
    flake = "github:brumik/config";
    dates = "Sun 17:00"; # Sunday at 5 PM
  };
}
