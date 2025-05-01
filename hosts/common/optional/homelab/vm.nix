{ config, pkgs, lib, ... }:
let
  cfg = config.homelab.home-assistant;
  subdomain = "ha";
  serviceName = "home-assistant-vm";

  usbDeviceArgs = lib.concatStringsSep " \\\n  " (map (id:
    let parts = lib.strings.splitString ":" id;
    in "-device usb-host,vendorid=0x${builtins.elemAt parts 0},productid=0x${
      builtins.elemAt parts 1
    }") cfg.usbDevices);
in {
  options.homelab.home-assistant = {
    enable = lib.mkEnableOption "homelab";

    image = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "The absolute path to the qcow2 image of HAOS";
      example = "/var/lib/haos.qcow2";
    };

    usbDevices = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "List of USB vendor:product IDs to pass through to the VM.";
      example = [ "1a86:7523" ];
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      (lib.assertMsg (cfg.image != "")
        "homelab.home-assistant.image must not be empty when home assistand is enabled.")
    ];

    # Enable libvirt and virtualization support
    virtualisation.libvirtd.enable = true;
    environment.systemPackages = with pkgs; [ qemu_kvm OVMF ];

    systemd.services.${serviceName} = {
      description = "Home Assistant VM";
      after = [ "libvirtd.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = ''
          ${pkgs.qemu_kvm}/bin/qemu-system-x86_64 \
          -name home-assistant \
          -machine type=q35,accel=kvm \
          -cpu host \
          -m 4096 \
          -smp 2 \
          -bios ${pkgs.OVMF.fd}/FV/OVMF.fd \
          -drive file=${cfg.image},format=qcow2,if=virtio \
          -netdev user,id=net0,hostfwd=tcp::8123-:8123 \
          -device virtio-net-pci,netdev=net0 \
          -nographic
          ${usbDeviceArgs}
        '';
        Restart = "always";
      };
    };

    homelab.backup = {
      stateDirs = [ cfg.image ]; # or wherever your `haDisk` points
      preBackupScripts = [ "systemctl stop ${serviceName}" ];
      postBackupScripts = [ "systemctl start ${serviceName}" ];
    };

    homelab.traefik.routes = [{
      host = subdomain;
      port = 8123;
    }];

    homelab.authelia.exposedDomains =
      [ "${subdomain}.${config.homelab.domain}" ];

    homelab.homepage.app = [{
      HomeAssistant = {
        icon = "home-assistant.png";
        href = "https://${subdomain}.${config.homelab.domain}";
        siteMonitor = "https://${subdomain}.${config.homelab.domain}";
        description = "Home automation platform";
      };
    }];
  };
}
