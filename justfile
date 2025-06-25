# default command to list other commands
default:
  @just --list

# rebuild the system from config
update:
  sudo nixos-rebuild switch --flake .

# print out all the trace while doing rebuild
update-debug:
  sudo nixos-rebuild switch --flake . --show-trace

# Create a age key from current machines ssh key (openssh needs to be enabled)
sops-ssh-to-age:
  nix-shell -p ssh-to-age --run 'cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age'

# This is the command to add or edit secrets in human readable form
sops-edit:
  EDITOR=nvim sops secrets.yaml

# Updating secrets after editing .sops.yml
sops-update:
  nix-shell -p sops --run "sops updatekeys secrets.yaml"

deploy-sleeper:
  sudo nixos-rebuild switch --flake .#sleeper --target-host root@sleeper.berky.me 

# Deploy the configuration to remote system
deploy-gamingrig:
  sudo nixos-rebuild switch --flake .#gamingrig --target-host root@gamingrig.berky.me 

# Deploy the configuration to remote system
deploy-anteater:
  sudo nixos-rebuild switch --flake .#anteater --target-host root@anteater.berky.me 

# Restore symlinks with stow (and simple script)
stow-mac:
  ./non-nix/stow/install.sh
  stow --dir=$(pwd)/non-nix/stow --target=$HOME .

# Build a bootable iso image outputted to ./result
build-live-iso:
  nix build .#nixosConfigurations.nixos-live.config.system.build.isoImage

# Build all nixos configurations
build-all:
  sudo ./build.sh
