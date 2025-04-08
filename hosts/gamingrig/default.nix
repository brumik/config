{ ... }: {
  imports = [
    ./hardware-configuration.nix

    ../common/core
    ../common/users/gamer.nix
  ];

  services.desktopManager.plasma6.enable = true;

  jovian = {
    hardware.has.amd.gpu = true;
    steam = {
      updater.splash = "vendor";
      enable = true;
      autoStart = true;
      user = "gamer";
      desktopSession = "plasma";
    };
    steamos = {
      useSteamOSConfig = true;
    };
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "gamingrig";
}
