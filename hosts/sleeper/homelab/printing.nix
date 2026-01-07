{ config, lib, pkgs, ... }:
let
  cfg = config.homelab.printing;
  hcfg = config.homelab;
in {
  options.homelab.printing = { enable = lib.mkEnableOption "printing"; };

  config = lib.mkIf (hcfg.enable && cfg.enable) {
    services.avahi = {
      enable = true;
      nssmdns4 = true;

      # share printer:
      openFirewall = true;
      publish = {
        enable = true;
        userServices = true;
      };
    };

    services.printing = {
      enable = true;
      # Setup brother printer
      drivers = [ pkgs.brlaser ];

      # share printer
      listenAddresses = [ "*:631" ];
      allowFrom = [ "all" ];
      browsing = true;
      defaultShared = true;
      openFirewall = true;
    };

    hardware.printers = {
      ensurePrinters = [{
        name = "Brother_HL_L2400DWE";
        location = "Home";
        deviceUri = "usb://Brother/HL-L2400DWE?serial=E83104A5N337483";
        model = "drv:///brlaser.drv/brl2400d.ppd";
        ppdOptions = { PageSize = "A4"; };
      }];
      ensureDefaultPrinter = "Brother_HL_L2400DWE";
    };
  };
}
