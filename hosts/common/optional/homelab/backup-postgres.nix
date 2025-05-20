{ config, lib, ... }:
let 
  cfg = config.homelab.postgresBackup;
in {
  options.homelab.postgresqlBackup = {
    baseDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/backup/postgresql";
      description = "The absolute path where the service will store the important informations";
    };
  };

  config = { 
    services.postgresqlBackup = {
      enable = config.services.postgresql.enable;
      location = cfg.baseDir;
      startAt = "*-*-* 23:00:00"; # do the backup every day befor the system is backed up
    };

    homelab.backup.stateDirs = [ cfg.baseDir ];
  };
}
