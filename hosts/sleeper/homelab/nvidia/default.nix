{ config, lib, pkgs, ... }:
let cfg = config.homelab.nvidia;
in {
  imports = [
    ./power.nix
  ];

  options.homelab.nvidia = {
    enable = lib.mkEnableOption "Nvidia";

    cachesEnabled = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Verifying that the user has enabled the cache. This is only assertion,
        it does not enable the cache. If set true but cache is not enabled builds
        can take hours.
      '';
    };
  };
  config = lib.mkIf cfg.enable {
    assertions = [{
      assertion = cfg.cachesEnabled;
      message = ''
        If community cache and nvidia caches are not enabled
        builds can take up to hours with nvidia support.
      '';
    }];

    # This enables cuda support in as many applications as possible.
    nixpkgs.config.cudaSupport = true;

    hardware.graphics = { enable = true; };
    services.xserver.videoDrivers = [ "nvidia" ];
    hardware.nvidia = {
      modesetting.enable = false;
      nvidiaPersistenced = true;
      open = true;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.production;
    };

    services.ollama.package = pkgs.ollama-cuda;

    # Docker nvidia
    # If enabled GPU idling at 30W instead of 20W;
    # hardware.nvidia-container-toolkit.enable = true;
    # virtualisation.docker.daemon.settings.features.cdi = true;
    # virtualisation.docker.rootless.daemon.settings.features.cdi = true;
  };
}
