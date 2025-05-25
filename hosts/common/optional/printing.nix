{ pkgs, ... }: {
  services.avahi = {
    enable = true;
    nssmdns4 = true;
  };
  services.printing = {
    enable = true;
    # Setup brother printer
    drivers = [ pkgs.brlaser ];
  };

  hardware.printers = {
    ensurePrinters = [{
      name = "Brother_HL_L2400DWE";
      location = "Home";
      deviceUri = "ipp://192.168.1.130/ipp";
      model = "drv:///brlaser.drv/brl2400d.ppd";
      ppdOptions = { PageSize = "A4"; };
    }];
    ensureDefaultPrinter = "Brother_HL_L2400DWE";
  };
}
