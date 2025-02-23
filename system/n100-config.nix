{ pkgs, ... }: {
  imports = [
    ./hardware/n100.nix
    ./modules/stylix-everforest.nix
    ./homelab
  ];

  #boot.loader.systemd-boot.enable = true;
  #boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
  };

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

  # Enable ssh
  services.openssh.enable = true;

  # Backup task
  systemd.services.rsyncBackup = {
    description = "Run rsync to backup the docker setup to SMB share";
    serviceConfig = {
      # This is dirty but as a server will do for now
      ExecStart = "${pkgs.bash}/bin/bash /home/n100/docker/rsync.sh"; # Script to run
      Environment = "PATH=${pkgs.coreutils}/bin:${pkgs.curl}/bin:${pkgs.rsync}/bin";
    };
  };

  systemd.timers.rsyncBackup = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 22:00:00";
      Persistent = true;
    };
  };

  # Services trying
  homelab = {
    enable = true;
    domain = "berky.me";
    serverIP = "192.168.1.127";
    gateway = "192.168.1.1";

    vaultwarden = {
      enable = true;
      address = "0.0.0.0";
      openFirewall = true;
    };

    adguardhome.enable = true;
    ddclient.enable = true;
    jellyfin.enable = true;
    # TODO This might be required by other services so need to add there?
    lldap.enable = true;
  };
}
