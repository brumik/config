{ pkgs, ... }: {
  boot.loader = {
    # Dpkgs, isable default system efi loader
    # and enable grub and allof it to scan
    # with os prober the whole disk to discover other installations
    systemd-boot.enable = pkgs.lib.mkForce false;
    efi.canTouchEfiVariables = true;
    grub = {
      enable = true;
      devices = [ "nodev" ];
      efiSupport = true;
      useOSProber = true;
    };
  };
  # Set time so windows works correctly
  time.hardwareClockInLocalTime = true;
}
