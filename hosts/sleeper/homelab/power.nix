{ config, lib, pkgs, ... }:
let
  cfg = config.homelab.power;
  hcfg = config.homelab;
in {
  options.homelab.power = { enable = lib.mkEnableOption "power"; };

  config = lib.mkIf (hcfg.enable && cfg.enable) {
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

    # Rotational disks: 1hour spindown
    services.udev.extraRules = ''
      ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", RUN+="${pkgs.hdparm}/sbin/hdparm -B 127 -S 242 /dev/%k"
    '';
  };
}
