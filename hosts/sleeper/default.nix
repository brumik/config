{ pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./disko.nix

    ../common/core
    ../common/optional/nvidia.nix
  ];

  # We need to use grub for mirroredBoot
  # boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "sleeper"; # Define your hostname.
  networking.hostId =
    "58cfdf5e"; # Generated from machine id, ensures we import zfs on correct machine

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
  # disko + settings needed
  myHome.disks = {
    enable = true;
    rootDisk1 = "/dev/disk/by-id/nvme-KINGSTON_SKC3000S512G_50026B7686F84D4B";
    rootDisk2 = "/dev/disk/by-id/nvme-KINGSTON_SKC3000S512G_50026B7383A70C89";
    rootReservation = "70G";
  };

  environment.systemPackages = with pkgs; [ zfs powertop pciutils hdparm ];
}
