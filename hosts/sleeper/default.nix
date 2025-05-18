{ config, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./disko.nix

    ../common/core
  ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = true;
    nvidiaSettings = false;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  networking.hostName = "sleeper"; # Define your hostname.
  # Generated from machine id, ensures we import zfs on correct machine
  # WARNING: changing this number will cause ZFS to fail import and keep hanging on boot
  networking.hostId = "20c133b5"; # head -c 8 /etc/machine-id

  # Powermanagement
  boot.kernelModules = [ "cpufreq_stats" ];
  powerManagement.powertop.enable = true;
  powerManagement.enable = true;
  # Alternatives: "ondemand", "performance"
  powerManagement.cpuFreqGovernor = "ondemand";
  # End of powermanagement

  # Disks management (power saving)
  # Spin down all rotational disks after (60*5) 300 seconds of inactivity
  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", RUN+="${pkgs.hdparm}/sbin/hdparm -S 60 /dev/%k"
  '';

  # Including setting up ZFS, impermanence and boot
  mySystems.disks = {
    enable = true;
    rootDisk1 = "/dev/disk/by-id/nvme-KINGSTON_SKC3000S512G_50026B7686F84D4B";
    rootDisk2 = "/dev/disk/by-id/nvme-KINGSTON_SKC3000S512G_50026B7383A70C89";
    rootReservation = "70G";
  };

  environment.systemPackages = with pkgs; [ zfs powertop pciutils hdparm ];
}
