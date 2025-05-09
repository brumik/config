# default command to list other commands
default:
  @just --list

# rebuild the system from config
update:
  sudo nixos-rebuild switch --flake .

# print out all the trace while doing rebuild
update-debug:
  sudo nixos-rebuild switch --flake . --show-trace

# updates the lockfile
upgrade:
  nix flake update && just update
  git add flake.lock
  git commit -m "lockfile update"
  git push

# clean old generations
clean:
  nix-collect-garbage -d

# Set up ssh agent and add the keys
set-up-ssh:
  eval "$(ssh-agent -s)"
  ssh-add

# Create a age key from current machines ssh key (openssh needs to be enabled)
sops-ssh-to-age:
  nix-shell -p ssh-to-age --run 'cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age'

# This is the command to add or edit secrets in human readable form
sops-edit:
  EDITOR=nvim sops secrets.yaml

# Updating secrets after editing .sops.yml
sops-update:
  nix-shell -p sops --run "sops updatekeys secrets.yaml"

# Check if the config is valid for all hosts
check: 
  nix flake check

# Deploy the configuration to remote system
deploy-n100:
  nixos-rebuild switch --flake .#n100 --target-host root@n100.berky.me 

deploy-sleeper:
  nixos-rebuild switch --flake .#sleeper --target-host root@sleeper.berky.me 

# Deploy the configuration to remote system
deploy-gamingrig:
  nixos-rebuild switch --flake .#gamingrig --target-host root@gamingrig.berky.me 

# Deploy the configuration to remote system
deploy-anteater:
  nixos-rebuild switch --flake .#anteater --target-host root@anteater.berky.me 

# Restore symlinks with stow (and simple script)
stow-mac:
  ./non-nix/stow/install.sh
  stow --dir=$(pwd)/non-nix/stow --target=$HOME .

# Build a bootable iso image outputted to ./result
build-live-iso:
  nix build .#nixosConfigurations.nixos-live.config.system.build.isoImage
