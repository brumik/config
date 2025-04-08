{ config, ... }:
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
  #TEMP
  # # Enable the X11 windowing system.
  # services.xserver.enable = true;
  # services.xserver.videoDrivers = [ "amdgpu" ];
  #
  # # Enable the GNOME Desktop Environment.
  # services.xserver.displayManager.gdm.enable = true;
  # services.xserver.desktopManager.gnome.enable = true;
  # #TEMP
  #
  # programs.steam = {
  #   enable = true;
  #   remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
  #   dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  #   localNetworkGameTransfers.openFirewall = true; 
  # };

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
