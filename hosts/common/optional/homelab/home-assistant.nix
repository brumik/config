{ config, pkgs, lib, ... }:
let
  cfg = config.homelab.home-assistant;
  serviceName = "home-assistant-vm";
in {
  options.homelab.home-assistant = {
    enable = lib.mkEnableOption "Home Assistant";

    image = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "The absolute path to the qcow2 image of HAOS";
      example = "/var/lib/haos.qcow2";
    };

    domain = lib.mkOption {
      type = lib.types.str;
      default = "ha";
      description = "The subdomain where the service will be served";
    };
  };

  config = lib.mkIf cfg.enable {
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
          -device qemu-xhci \
          -nographic \
          -device usb-host,vendorid=0x1a86,productid=0x55d4 \
          -device usb-host,vendorid=0x1cf1,productid=0x0030 \
          -device usb-host,vendorid=0x0658,productid=0x0200
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
      host = cfg.domain;
      port = 8123;
    }];

    homelab.authelia.exposedDomains =
      [ "${cfg.domain}.${config.homelab.domain}" ];

    homelab.homepage.app = [{
      HomeAssistant = {
        icon = "home-assistant.png";
        href = "https://${cfg.domain}.${config.homelab.domain}";
        siteMonitor = "https://${cfg.domain}.${config.homelab.domain}";
        description = "Home automation platform";
      };
    }];
  };
}
