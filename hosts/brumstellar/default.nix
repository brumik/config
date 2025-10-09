{ config, pkgs, ... }: {
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
    ../common/optional/usb-waekup-disable.nix

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

  # Trust the network to enable playing LAN games
  networking.firewall.trustedInterfaces = [ "wlp5s0" ];

  hardware.usb.wakeupDisabled = [{
    vendor = "046d";
    product = "c548";
  }];

  # Disable typing the password then using sudo
  security.sudo.wheelNeedsPassword = false;

  # Enable software monitor brightness controll
  hardware.i2c.enable = true;
  environment.systemPackages = with pkgs; [ ddcutil ];

  # Add it to gnome so it can controll it (does not work)
  # boot.extraModulePackages = with config.boot.kernelPackages; [ ddcci-driver ];
  # boot.kernelModules = [ "ddcci-backlight" ];
  # services.udev.extraRules = let
  #   bash = "${pkgs.bash}/bin/bash";
  #   # $ cat /sys/bus/i2c/devices/i2c-<your device>/name                     
  #   ddcciDev = "AMDGPU DM aux hw bus 0";
  #   ddcciNode = "/sys/bus/i2c/devices/i2c-5/new_device";
  # in ''
  #   SUBSYSTEM=="i2c", ACTION=="add", ATTR{name}=="${ddcciDev}", RUN+="${bash} -c 'sleep 30; printf ddcci\ 0x37 > ${ddcciNode}'"
  # '';
  
  boot.supportedFilesystems = [ "nfs" ];
  fileSystems."/mnt/brum" = {
    device = "sleeper.berky.me:/brum";
    fsType = "nfs"; options = [ "nfsvers=4.2" "x-systemd.automount" "noauto" ];
  };
}
