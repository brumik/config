{ config, ... }:
{
  # If using docker, enable docker containers
  hardware.nvidia-container-toolkit.enable = true;

  # Enable OpenGL
  hardware.graphics = {
    enable = true;
  };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    # Modesetting is required.
    modesetting.enable = true;

    # experimental and can cause sleep/suspend to fail
    powerManagement.enable = false;
    # Fine-grained power management. Turns off GPU when not in use.
    # Only for Laptops
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # If your GPU is supported nvidia recommends using this
    # supported GPUs is at: 
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
    # Only available from driver 515.43.04+

    # TODO: BUG: if enabled the camera feed will display blank if aplied any effect on video in chromium
    open = false;

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

}
