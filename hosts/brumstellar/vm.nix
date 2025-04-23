{ pkgs, ... }:
let haDisk = "/home/levente/Downloads/haos_ova-15.2.qcow2"; # adjust if stored elsewhere
in {
  imports = [ ];

  # Enable libvirt and virtualization support
  virtualisation.libvirtd.enable = true;
  environment.systemPackages = with pkgs; [
    qemu_kvm
    OVMF
  ];
  users.users.levente.extraGroups =
    [ "libvirtd" ]; # make sure you can manage VMs

  systemd.services.home-assistant-vm = {
    description = "Home Assistant VM";
    after = [ "libvirtd.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = ''
        ${pkgs.qemu_kvm}/bin/qemu-system-x86_64 \
        -name home-assistant \
        -machine type=q35,accel=kvm \
        -cpu host \
        -m 2048 \
        -smp 2 \
        -bios ${pkgs.OVMF.fd}/FV/OVMF.fd \
        -drive file=${haDisk},format=qcow2,if=virtio \
        -netdev user,id=net0,hostfwd=tcp::8123-:8123 \
        -device virtio-net-pci,netdev=net0 \
        -nographic
      '';
      Restart = "always";
    };
  };
}
