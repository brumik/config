{ config, pkgs, ... }:
let uname = "gamer";
in {
  imports = [
    ./hardware-configuration.nix

    ../common/core
  ];

  networking.hostName = "gamingrig";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  hardware.xone.enable = true;

  services.desktopManager.plasma6.enable = true;

  jovian = {
    hardware.has.amd.gpu = true;
    steam = {
      updater.splash = "vendor";
      enable = true;
      autoStart = true;
      user = "${uname}";
      desktopSession = "plasma";
    };
    steamos = { useSteamOSConfig = false; };
  };

  environment.systemPackages = with pkgs; [
    curl
    git
    vim
    jellyfin-media-player
    brave
  ];

  sops.secrets."brum/hashed-password".neededForUsers = true;
  # It's important to include users.mutableUsers = false to ensure the user can't modify
  # their password or groups. Furthermore, if the user had already been created prior to
  # setting their password this way, their existing password will not be overwritten
  # unless this option is false.
  users.mutableUsers = false;

  users.users."${uname}" = {
    uid = 1000;
    isNormalUser = true;
    description = "Gamer";
    extraGroups = [ "networkmanager" "wheel" ];
    hashedPasswordFile = config.sops.secrets."brum/hashed-password".path;
  };

}
