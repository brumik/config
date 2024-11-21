{ pkgs, ... }: {
  imports = [
    ./hardware/n100.nix
    # ./modules/base-configuration.nix
    # ./modules/stylix-default.nix
    ./modules/stylix-everforest.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    curl
    git
    vim
  ];

  environment.shells = with pkgs; [ zsh ];
  users.defaultUserShell = pkgs.zsh;
  programs.zsh.enable = true;
  
  nix.optimise = {
    automatic = true;
    dates = ["10:00"];
  };

  nix.gc = {
    automatic = true;
    dates = "10:00";
    options = "--delete-older-than 7d";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  networking.hostName = "nixos-n100"; # Define your hostname.

  # Server preparation
  # ===========================

  # Enable binding on the 80 and 443 port for docker
  boot.kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = 0;

  # Enable ssh
  services.openssh.enable = true;

  # Set up ddclient for setting the IP for berky.me to the ip of the network
  services.ddclient = {
    enable = true;
    configFile = "/home/n100/ddclient.conf";
  };
}
