{ pkgs, ... }: let
  DOMAINNAME = "berky.me";
  SERVER_ADDR = "192.168.1.127";
in {
  imports = [
    ./hardware/n100.nix
    ./modules/stylix-everforest.nix
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

  # Get static ip address instead of dhcp
  networking = {
    useDHCP = false; # Disable DHCP to allow static IP configuration

    interfaces = {
      ens18 = {
        ipv4.addresses = [
          {
            address = "192.168.1.127"; # Your desired static IP address
            prefixLength = 32;         # Subnet mask in CIDR notation
          }
        ];
      };
    };

    defaultGateway = "192.168.1.1";
    # DNS settings
    nameservers = [ "1.1.1.1" "8.8.8.8" ]; # Replace with your preferred DNS servers
  };

  # For not using it's own servers
  # networking.nameservers = [ "1.1.1.1" ];

  # Enable binding on the 80 and 443 port for docker
  boot.kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = 0;

  # Open ports for reverse proxy
  networking.firewall.allowedTCPPorts = [ 80 443 ];
  # Open ports for DNS server
  networking.firewall.allowedUDPPorts = [ 53 ];

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
  services.ddclient = {
    enable = true;
    use = "web, web=ip.websupport.sk/";
    ssl = true;
    protocol = "dyndns2";
    server = "dyndns.websupport.sk";
    username = "3a2bf436-c280-43f3-97b9-d71c27172191";
    passwordFile = "/home/n100/ddclient.key";
    extraConfig = "wildcard=yes";
    domains = [ "berky.me" ];
  };

  services.adguardhome = {
    enable = true;
    host = "0.0.0.0";
    port = 10000;
    openFirewall = true;
    settings = {
      dns = {
        upstream_dns = [
          "quic://dns-unfiltered.adguard.com:784"
          "https://dns.cloudflare.com/dns-query"
          "https://dns10.quad9.net/dns-query"
        ];
      };
      filtering = {
        rewrites = [
          {
            domain = "*.${DOMAINNAME}";
            answer = "${SERVER_ADDR}";
          }
          {
            domain = "${DOMAINNAME}";
            answer = "${SERVER_ADDR}";
          }
        ];
      };
    };
  };


  # services.vaultwarden = {
  #   enable = true;
  #   config = {
  #     DOMAIN = "https://bitwarden.${DOMAINNAME}";
  #     SIGNUPS_ALLOWED = false;
  #     ROCKET_ADDRESS = "0.0.0.0";
  #     ROCKET_PORT = 10001;
  #   };
  # };
}
