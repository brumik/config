{ config, lib, pkgs, ... }:
with lib;
let cfg = config.mySystems.disks;
in {
  options.mySystems.disks = {
    enable = mkEnableOption "disks";

    rootPool = mkOption {
      type = types.str;
      description = "Name of the root pool";
      default = "rpool";
    };

    dataPool = mkOption {
      type = types.str;
      description = "Name of the data pool";
      default = "dpool";
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

    dataDisk1 = mkOption {
      type = types.nullOr types.str;
      description = "First Hdd disk on which to set up SSD.";
      example = "/dev/hdd1";
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
    environment.systemPackages = with pkgs; [ zfs ];

    # General config for this setup:
    boot.supportedFilesystems = [ "zfs" ];
    boot.zfs.forceImportRoot = false;

    # Set up Mirrored Boot disks. This is only doable with GRUB right now
    # so we need to enable grub as our bootloader.
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.grub = {
      enable = true;
      efiSupport = true;
      efiInstallAsRemovable = false;

      # Set up mirrored boot disks
      mirroredBoots = [
        {
          path = "/boot";
          # we use efi so nodev
          devices = [ "nodev" ];
        }
        {
          path = "/boot2";
          devices = [ "nodev" ];
        }
      ];
    };

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
        data1 = {
          type = "disk";
          device = cfg.dataDisk1;
          content = {
            type = "gpt";
            partitions = {
              zfs = {
                size = "100%";
                content = {
                  type = "zfs";
                  pool = cfg.dataPool;
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
            };

            "local/nix" = {
              type = "zfs_fs";
              mountpoint = "/nix";
              options.mountpoint = "legacy";
            };

            "safe/home" = {
              type = "zfs_fs";
              mountpoint = "/home";
              options."com.sun:auto-snapshot" = "true";
              options.mountpoint = "legacy";
            };

            "safe/persist" = {
              type = "zfs_fs";
              mountpoint = "/persist";
              options."com.sun:auto-snapshot" = "true";
              options.mountpoint = "legacy";
            };
          };
        };
        ${cfg.dataPool} = {
          type = "zpool";
          # mode = "mirror";
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
            "backup" = {
              type = "zfs_fs";
              mountpoint = "/backup";
              options."com.sun:auto-snapshot" = "true";
              options.mountpoint = "legacy";
            };

            "photos" = {
              type = "zfs_fs";
              mountpoint = "/photos";
              options."com.sun:auto-snapshot" = "true";
              options.mountpoint = "legacy";
            };

            "media" = {
              type = "zfs_fs";
              mountpoint = "/media";
              options."com.sun:auto-snapshot" = "true";
              options.mountpoint = "legacy";
            };
          };
        };
      };
    };
  };
}
