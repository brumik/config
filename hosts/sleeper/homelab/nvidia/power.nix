{ config, lib, pkgs, ... }:
let
  cfg = config.homelab.nvidia.power;
  GPU_ID = 0;
  POWER_THRESHOLD = 29;
in {
  options.homelab.nvidia.power = {
    enable = lib.mkEnableOption "Nvidia power";

    limit = lib.mkOption {
      type = lib.types.nullOr lib.types.int;
      default = null;
      description =
        "Limit the max W of the GPU. If null then no change to default.";
    };
  };
  config = lib.mkIf cfg.enable {
    # On startup set the power limit
    systemd.services.nvidia-power-limit-high = {
      description = "Set NVIDIA power limit to ${toString cfg.limit} on boot";
      path = [ config.hardware.nvidia.package ];
      script = ''
        nvidia-smi --id=${toString GPU_ID} -pl ${toString cfg.limit}
      '';
      wantedBy = [ "multi-user.target" ];
      serviceConfig = { Type = "oneshot"; };
    };

    # Reset the GPU if stuck in a higher power P8 state:
    systemd.services.nvidia-idle-reset = {
      description = "Reset NVIDIA GPU if idle but drawing high power in P8";
      path = [ config.hardware.nvidia.package pkgs.coreutils pkgs.gawk ];
      script = ''
        set -euo pipefail

        # Count running compute processes
        PROC_COUNT=$(nvidia-smi \
          --id=${toString GPU_ID} \
          --query-compute-apps=pid \
          --format=csv,noheader | wc -l)

        # Read power state
        PSTATE=$(nvidia-smi \
          --id=${toString GPU_ID} \
          --query-gpu=pstate \
          --format=csv,noheader | tr -d ' ')

        # Read power draw (integer watts)
        POWER_DRAW=$(nvidia-smi \
          --id=${toString GPU_ID} \
          --query-gpu=power.draw \
          --format=csv,noheader,nounits | awk '{printf "%d\n", $1}')

        if [ "$PROC_COUNT" -eq 0 ] && \
           [ "$PSTATE" = "P8" ] && \
           [ "$POWER_DRAW" -gt ${toString POWER_THRESHOLD} ]; then
          nvidia-smi --id=${toString GPU_ID} -r
          nvidia-smi --id=${toString GPU_ID} -pl ${toString cfg.limit}
        fi
      '';
      serviceConfig = { Type = "oneshot"; };
    };

    systemd.timers.nvidia-idle-reset = {
      description = "Check idle NVIDIA GPU power usage every 10 minutes";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "5min";
        OnUnitActiveSec = "10min";
        AccuracySec = "1min";
        Unit = "nvidia-idle-reset.service";
      };
    };
  };
}
