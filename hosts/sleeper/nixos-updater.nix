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

      echo "Entering the $REPO_DIR"
      cd $REPO_DIR

      # Clone or pull the repository
      if [ ! -d ".git" ]; then
        echo "Cloning the repo"
        git clone "https://$${GITHUB_TOKEN}@github.com/brumik/config.git" ./
      else
        echo "Updating the repo"
        git fetch origin
        git reset --hard origin/main
      fi

      echo "Setting up the username and password"
      git config user.email "sleeper@berky.com"
      git config user.name "Sleeper Server"

      # Update flakes
      nix flake update --accept-flake-config

      # Check flakes
      nix flake check --accept-flake-config

      # Build
      ${builtins.concatStringsSep "\n\n" (map (host: ''
        echo "Building NixOS configuration for: ${host}"
        nix build ".#nixosConfigurations.${host}.config.system.build.toplevel" --accept-flake-config || {
          echo "Failed to build ${host}"
          exit 1
        }
      '') hosts)}

      # Commit and push
      echo "Build success, pushing the updates to git"
      git add .
      git commit -m "Automated update and build"
      git push origin main
    '';
  };
in {
  sops.secrets = { "n100/update-flake/github-token" = { }; };
  sops.templates."n100/update-flake/.env" = {
    content = ''
      GITHUB_TOKEN=${config.sops.placeholder."n100/update-flake/github-token"}
    '';
  };

  systemd.services.update-flake = {
    description = "Run update every Sunday at 8 AM";


    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${update-flake}/bin/update-flake.sh";
      EnvironmentFile = config.sops.templates."n100/update-flake/.env".path;
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
