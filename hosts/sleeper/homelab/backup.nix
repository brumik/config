{ config, lib, pkgs, ... }:
let
  cfg = config.homelab.backup;
  hcfg = config.homelab;

  emailScript = pkgs.writeShellScript "restic-check-and-email" ''
    #!/bin/sh

    tmpfile=$(mktemp)
    cat > "$tmpfile" << EOF
    Subject: Restic Backup Check Report
    To: ${hcfg.email.addr}
    From: sleeper@berky.me

    Restic check started at $(date)
    List of directories:
    ${builtins.concatStringsSep "\n" cfg.stateDirs}


    Restic check results:
    $(/run/current-system/sw/bin/restic-remotebackup check)


    Check completed at $(date)
    EOF

    ${lib.getExe pkgs.msmtp} -t < "$tmpfile"
  '';

in {
  options.homelab.backup = {
    enable = lib.mkEnableOption "backup";

    stateDirs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "The directories to be backed up as absolute path.";
    };

    preBackupScripts = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Shell scripts to run before the restic backup.";
      example = [ "virsh suspend myvm" ];
    };

    postBackupScripts = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Shell scripts to run after the restic backup.";
      example = [ "virsh resume myvm" ];
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      users.users.restic = { isNormalUser = true; };
      sops.secrets."n100/restic/password" = { owner = "restic"; };
      sops.secrets."n100/restic/id_hetzner_pub" = { owner = "restic"; };
      sops.secrets."n100/restic/id_hetzner" = { owner = "restic"; };

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
          repository = "sftp::/home/backup";
          extraOptions = [
            "sftp.command='ssh u463932@u463932.your-storagebox.de -p 23 -i ${
              config.sops.secrets."n100/restic/id_hetzner".path
            } -s sftp'"
          ];
          passwordFile = config.sops.secrets."n100/restic/password".path;
          pruneOpts = [ "--keep-daily 7" ];
          timerConfig = { OnCalendar = "00:01"; };
          backupPrepareCommand =
            builtins.concatStringsSep "\n" cfg.preBackupScripts;
          backupCleanupCommand =
            builtins.concatStringsSep "\n" cfg.postBackupScripts;
        };
      };
    })
    (lib.mkIf hcfg.email.enable {
      systemd.services.restic-remotebackup-email = {
        description = "Restic Check and Email Results";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${emailScript}";
        };
      };

      systemd.timers.restic-remotebackup-email = {
        description = "Weekly Restic Check Email Timer";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "Sun 10:00";
          Persistent = true;
        };
      };
    })
  ];
}
