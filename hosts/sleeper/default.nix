{ pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../common/core

    ../common/optional/nvidia.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "sleeper"; # Define your hostname.

  services.ollama = {
    enable = false;
    acceleration = "cuda";
    host = "0.0.0.0";
    port = 11434;
    loadModels = [ "gemma3:27b" "deepseek-r1:32b" "mxbai-embed-large" ];
  };

  # Powermanagement
  boot.kernelModules = [ "cpufreq_stats" ];
  boot.kernelParams = [ "pcie_aspm=force" "acpi_enforce_resources=lax" ];
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

  # AI Web UI testing
  services.open-webui = {
    enable = true;
    host = "0.0.0.0";
    port = 11111;
    environment = {
      OLLAMA_API_BASE_URL = "http://127.0.0.1:11434";
      # Disable authentication
      WEBUI_AUTH = "False";
    };
  };

  # Open firewall for ollama
  networking.firewall.allowedTCPPorts = [ 11434 11111 ];

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
