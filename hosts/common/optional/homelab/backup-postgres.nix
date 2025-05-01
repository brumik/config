{ config, ... }:
let dir = "/var/backup/postgresql";
in {
  services.postgresBackup = {
    enable = config.services.postgresql.enable;
    location = dir;
    startAt = "*-*-* 23:00:00"; # do the backup every day befor the system is backed up
  };

  homelab.backup.stateDirs = [ dir ];
}
