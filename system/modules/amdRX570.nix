{ ... }: {
  boot.initrd.kernelModules = [ "amdgpu" ];
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "amdgpu" ];
  environment.variables = {
    ROC_ENABLE_PRE_VEGA = "1";
  };
}
