{ pkgs, lib, ... }:

let
  # Wrapper script to run abcde and eject
  ripCdScript = pkgs.writeShellApplication {
    name = "ripCdScript";
    runtimeInputs = [ pkgs.abcde pkgs.flac pkgs.eject pkgs.gawk pkgs.hostname ];
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail

      abcde -c /home/levente/config/non-nix/media_helpers/abcde.conf
    '';
  };
in {
  # Systemd template service
  systemd.services."rip-cd" = {
    description = "Rip CD";
    wants = [ "dev-sr0.device" ];
    after = [ "dev-sr0.device" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = lib.getExe ripCdScript;
    };
  };

  # Udev rule to trigger service on CD insert
  services.udev.extraRules = ''
    ACTION=="change", KERNEL=="sr0", ENV{ID_CDROM_MEDIA_TRACK_COUNT_AUDIO}!="0", \
      RUN+="${lib.getExe' pkgs.systemd "systemctl"} start rip-cd.service"
  '';
}
