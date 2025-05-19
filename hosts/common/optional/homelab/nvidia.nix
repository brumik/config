{ config, lib, ... }: {
  config = lib.mkIf (config.homelab.gpu == "nvidia") {
    hardware.nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      open = true;
      nvidiaSettings = false;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  };
}
