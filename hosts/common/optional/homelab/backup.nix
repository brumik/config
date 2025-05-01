{ config, lib, pkgs, ... }:
let cfg = config.homelab.backup;
in {
  options.homelab.backup = {
    enable = lib.mkEnableOption "backup";

    stateDirs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.restic = { isNormalUser = true; };
    sops.secrets."n100/restic-password" = {
      owner = "restic";
    };

    security.wrappers.restic = {
      source = "${pkgs.restic.out}/bin/restic";
      owner = "restic";
      group = "share";
      permissions = "u=rwx,g=,o=";
      capabilities = "cap_dac_read_search=+ep";
    };

    services.restic.backups = {
      remotebackup = {
        initialize = true;
        paths = cfg.stateDirs;
        repository = "/mnt/share/resticBackup";
        passwordFile = config.sops.secrets."n100/restic-password".path;
        pruneOpts = [ "--keep-daily 4" ];

        timerConfig = {
          OnCalendar = "00:01";
        };
      };
    };
  };
}
