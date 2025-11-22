{ config, pkgs, ... }:
let gamer = config.globals.users.gamer;
in {
  imports = [
    ./hardware-configuration.nix

    ../common/core
    ../common/optional/usb-waekup-disable.nix
  ];

  networking.hostName = "gamingrig";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  hardware.xone.enable = true;
  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot

  hardware.usb.wakeupDisabled = [{
    # logitech bolt reciever (mouse but not the kb)
    vendor = "046d";
    product = "c548";
  }];

  services.desktopManager.plasma6.enable = true;
  jovian = {
    hardware.has.amd.gpu = true;
    steam = {
      updater.splash = "vendor";
      enable = true;
      autoStart = true;
      user = gamer.uname;
      desktopSession = "plasma";
    };
    steamos = { useSteamOSConfig = false; };
  };


  # Trust the network to enable playing LAN games
  networking.firewall.trustedInterfaces = [ "wlp9s0" ];

  environment.systemPackages = with pkgs; [
    curl
    git
    vim
    brave
    discord
  ];

  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
  };

  sops.secrets."brum/hashed-password".neededForUsers = true;
  # It's important to include users.mutableUsers = false to ensure the user can't modify
  # their password or groups. Furthermore, if the user had already been created prior to
  # setting their password this way, their existing password will not be overwritten
  # unless this option is false.
  users.mutableUsers = false;

  users.users.${gamer.uname} = {
    uid = gamer.uid; 
    isNormalUser = true;
    description = "Gamer";
    extraGroups = [ "networkmanager" "wheel" ];
    hashedPasswordFile = config.sops.secrets."brum/hashed-password".path;
  };
}
