{ config, lib, ... }:
let cfg = config.homelab.nvidia.power;
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
    systemd.services.nvidia-power-limit-high = {
      description = "Set NVIDIA power limit to ${toString cfg.limit} on boot";
      path = [ config.hardware.nvidia.package ];
      script = ''
        nvidia-smi -pl ${toString cfg.limit}
      '';
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
      };
    };
  };
}
