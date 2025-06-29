{ config, pkgs, ... }:
let
  hosts = [ "brumstellar" "anteater" "sleeper" "gamingrig" "nixos-live" ];
  update-flake = pkgs.writeShellApplication {
    name = "update-flake.sh";
    runtimeInputs = [ pkgs.nix pkgs.git ];
    text = ''
      #!/bin/bash

      set -e

      # Local directory for the repository
      REPO_DIR="/etc/brumik/config"  # Replace with your desired path

      # Create the directory if it doesn't exist
      mkdir -p "$REPO_DIR"

      cd $REPO_DIR

      git config user.email "sleeper@berky.com"
      git config user.name "Sleeper Server"

      # Clone or pull the repository
      if [ ! -d ".git" ]; then
        git clone "git@github.com/brumik/config.git" "$REPO_DIR"
      else
        git fetch origin
        git reset --hard origin/main
      fi

      # Update flakes
      nix flake update --accept-flake-config

      # Check flakes
      nix flake check --accept-flake-config

      # Build
      ${builtins.concatStringsSep "\n\n" (map (host:
        ''
        echo "Building NixOS configuration for: ${host}"
        nix build ".#nixosConfigurations.${host}.config.system.build.toplevel" --accept-flake-config || {
          echo "Failed to build ${host}"
          exit 1
        }
        ''
      ) hosts)}

      # Commit and push
      git add .
      git commit -m "Automated update and build"
      git push origin main
    '';
  };
in {
  sops.secrets = { "private-keys/id-n100-github" = { }; };

  programs.ssh.extraConfig = ''
    Host github.com
        IdentityFile ${config.sops.secrets."private-keys/id-n100-github".path}
        IdentitiesOnly yes
  '';

  systemd.services.update-flake = {
    description = "Run update every Sunday at 8 AM";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${update-flake}/bin/update-flake.sh";
    };
  };

  systemd.timers.update-flake = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "Mon 4:30";
      Persistent = true;
    };
  };
}
