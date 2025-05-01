{ pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../common/core

    ../common/optional/nvidia.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "sleeper"; # Define your hostname.

  # Powermanagement
  boot.kernelModules = [ "cpufreq_stats" ];
  powerManagement.powertop.enable = true;
  powerManagement.enable = true;
  powerManagement.cpuFreqGovernor =
    "ondemand"; # Alternatives: "ondemand", "performance"
  # End of powermanagement

  # Disks management (power saving)
  # Spin down all rotational disks after (60*5) 300 seconds of inactivity
  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", RUN+="${pkgs.hdparm}/sbin/hdparm -S 60 /dev/%k"
  '';

  # ZFS
  # Generated from machine id, ensures we import zfs on correct machine
  networking.hostId = "58cfdf5e";

  boot.supportedFilesystems = [ "zfs" ];

  # here we specify which exact pools to import at startup
  boot.zfs.extraPools = [ "tank" ];

  services.zfs = {
    autoScrub.enable = true; # optional: enables periodic scrubbing
    trim.enable = true; # optional: enables TRIM if supported
  };

  environment.systemPackages = with pkgs; [
    zfs
    powertop
    pciutils
    hdparm
  ];
}
