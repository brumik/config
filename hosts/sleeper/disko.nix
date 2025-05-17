{ config, lib, ... }:
with lib;
let cfg = config.myHome.disks;
in {
  options.myHome.disks = {
    enable = mkEnableOption "disks";

    rootPool = mkOption {
      type = types.str;
      description = "Name of the root pool";
      default = "root";
    };

    rootDisk1 = mkOption {
      type = types.str;
      description = "SSD disk on which to install.";
      example = "/dev/nvme0";
    };

    rootDisk2 = mkOption {
      type = types.nullOr types.str;
      description = "Second SSD disk on which to install.";
      example = "/dev/nvme1";
    };

    rootReservation = mkOption {
      type = types.str;
      description = ''
        Disk size to reserve for ZFS internals. Should be between 10% and 15% of available size as recorded by zpool.

        To get available size on zpool:

           zfs get -Hpo value available ${opt.rootPool}

        Then to set manually, if needed:

           sudo zfs set reservation=100G ${opt.rootPool}
      '';
      example = "100G";
    };
  };

  config = mkIf cfg.enable {
    # General config for this setup:
    boot.supportedFilesystems = [ "zfs" ];
    boot.zfs.forceImportRoot = false;

    # Set up Mirrored Boot disks. This is only doable with GRUB right now
    # so we need to enable grub as our bootloader.
    boot.loader.grub = {
      enable = true;
      efiSupport = true;
      efiInstallAsRemovable = false;
      # Install grub on both devices, so we can use it if one disk fails.
      # TODO: we do not need this because we do efi
      # devices = [ cfg.rootDisk1 cfg.rootDisk2 ];

      # Set up mirrored boot disks
      mirroredBoots = [
        {
          path = "/boot";
          # we use efi so nodev
          devices = [ "nodev" ];
          # devices = [ cfg.rootDisk1 ];
        }
        {
          path = "/boot2";
          # we use efi so nodev
          devices = [ "nodev" ];
        }
      ];
    };

    # Follows https://grahamc.com/blog/erase-your-darlings/
    # https://github.com/NixOS/nixpkgs/pull/346247/files
    boot.initrd.postResumeCommands = lib.mkAfter ''
      zfs rollback -r ${cfg.rootPool}/local/root@blank
    '';

    # setting up the disks
    disko.devices = {
      disk = {
        root1 = {
          type = "disk";
          device = cfg.rootDisk1;
          content = {
            type = "gpt";
            partitions = {
              ESP = {
                size = "1G";
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                  mountOptions = [ "umask=0077" "nofail" ];
                };
              };
              zfs = {
                size = "100%";
                content = {
                  type = "zfs";
                  pool = cfg.rootPool;
                };
              };
            };
          };
        };
        root2 = {
          type = "disk";
          device = cfg.rootDisk2;
          content = {
            type = "gpt";
            partitions = {
              ESP = {
                size = "1G";
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot2";
                  mountOptions = [ "umask=0077" "nofail" ];
                };
              };
              zfs = {
                size = "100%";
                content = {
                  type = "zfs";
                  pool = cfg.rootPool;
                };
              };
            };
          };
        };
      };
      zpool = {
        ${cfg.rootPool} = {
          type = "zpool";
          mode = "mirror";
          options = {
            # good for ssds
            ashift = "12";
            autotrim = "on";
          };
          rootFsOptions = {
            # compression should be 2.5 to 1 sohuld be fine on modern cpu
            compression = "zstd";
            "com.sun:auto-snapshot" = "false";
          };
          datasets = {
            # following: https://grahamc.com/blog/erase-your-darlings/
            # tldr: deletes all on each reboot exept /persist. Link all important data to it.
            "reserved" = {
              options = {
                canmount = "off";
                mountpoint = "none";
                reservation = cfg.rootReservation;
              };
              type = "zfs_fs";
            };

            "local/root" = {
              type = "zfs_fs";
              mountpoint = "/";
              options.mountpoint = "legacy";
              postCreateHook =
                "zfs list -t snapshot -H -o name | grep -E '^${cfg.rootPool}/local/root@blank$' || zfs snapshot ${cfg.rootPool}/local/root@blank";
            };

            "local/nix" = {
              type = "zfs_fs";
              mountpoint = "/nix";
              options.mountpoint = "legacy";
            };

            "safe/home" = {
              type = "zfs_fs";
              mountpoint = "/home";
              options.mountpoint = "legacy";
            };

            "safe/persist" = {
              type = "zfs_fs";
              mountpoint = "/persist";
              options.mountpoint = "legacy";
            };
          };
        };
      };
    };
  };
}
