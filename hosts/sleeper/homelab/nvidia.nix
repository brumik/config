{ config, lib, ... }:
let cfg = config.homelab.nvidia;
in {
  options.homelab.nvidia = { enable = lib.mkEnableOption "Nvidia"; };
  config = lib.mkIf cfg.enable {
    # What is this? It probably can make immich on GPU work?
    # This enables cuda support in as many applications as possible.
    # To enable this make sure you set up community cache...
    nixpkgs.config.cudaSupport = true;
    
    # Docker nvidia
    hardware.nvidia-container-toolkit.enable = true;
    virtualisation.docker.daemon.settings.features.cdi = true;
    virtualisation.docker.rootless.daemon.settings.features.cdi = true;

    hardware.graphics = { enable = true; };
    services.xserver.videoDrivers = ["nvidia"];
    hardware.nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };

    services.ollama = {
      acceleration = "cuda";
    };
  };
}
