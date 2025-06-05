{ config, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./stylix.nix

    ../common/core
    ../common/optional/base-gnome.nix
    ../common/optional/sound.nix
    ../common/optional/docker.nix
    ../common/optional/smb.nix
    ../common/optional/scanner.nix
    ../common/optional/sound.nix
    ../common/optional/gaming.nix
    ../common/optional/printing.nix

    ../common/users/levente.nix
    ../common/users/work.nix
  ];

  # mySystems.smb = {
  #   enable = true;
  #   credentials = config.sops.secrets."brum/smb-credentials".path;
  # };

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

  # Hyprland part
  programs.hyprland = { enable = true; };
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  security.pki.certificateFiles = [
    ./MODMED.pem
    # ./trusted_certs.pem
    ./test.pem
    # ./BPClass2CA2Bundle.pem
    # ./CiscoRootCA2048.cer
    # ./BuypassClass2RootCA.cer
    # ./BuypassClass3RootCA.cer
  ];

  # services.strongswan = {
  #   enable = true;
  #
  #   secrets = [ "/home/levente/config/hosts/brumstellar/secrets" ];
  #
  #   connections = {
  #     boca = {
  #       dpdaction = "restart";
  #       dpddelay = "30";
  #       dpdtimeout = "90";
  #       fragmentation = "yes";
  #       leftsourceip = "%config";
  #       keyexchange = "ikev2";
  #       right = "cerberus-boca-1.corp.modmed.com";
  #       rightcert="/home/levente/config/MODMED.pem";
  #       leftauth = "eap_mschapv2";
  #       rightauth = "pubkey";
  #       rightsubnet = "0.0.0.0/0";
  #       auto = "add";
  #
  #       # rightid = "cerberus-boca-1.corp.modmed.com";
  #       # rightcert="/home/levente/config/MODMED.pem";
  #       # leftid = "levente.berky";
  #       # eap_identity = "%identity";
  #     };
  #   };
  # };
  services.dbus.packages = [ pkgs.networkmanager pkgs.strongswanNM ];
  networking.networkmanager = {
    enable = true;
    plugins = [ pkgs.networkmanager_strongswan ];
  };
  # extra packages
  environment.systemPackages = with pkgs;
    [
      libnotify # testing out notification daemon
      strongswan # for ipsec
      strongswanNM
    ];

  # screen sharing capabilities
  # seems same as sound.nix
  # need to enable pipewire and pipewire.wireplumber (default true)
}
