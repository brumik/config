{ config, lib, pkgs, ... }:
let cfg = config.homelab.power;
in {
  options.homelab.power = { enable = lib.mkEnableOption "power"; };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      powertop
      pciutils
      hdparm
      cpufrequtils
    ];

    powerManagement.powertop.enable = true;
    powerManagement.enable = true;
    # Alternatives: "ondemand", "performance"
    powerManagement.cpuFreqGovernor = "ondemand";

    # Spin down all rotational disks after 30min of inactivity
    services.udev.extraRules = ''
      ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", RUN+="${pkgs.hdparm}/sbin/hdparm -S 241 /dev/%k"
    '';
  };
}
