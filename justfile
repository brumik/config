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

# clean old generations
clean:
  nix-collect-garbage -d

# Set up ssh agent and add the keys
set-up-ssh:
  eval "$(ssh-agent -s)"
  ssh-add

# Restore symlinks with stow (and simple script)
stow-mac:
  ./non-nix/stow/install.sh
  stow --dir=$(pwd)/non-nix/stow --target=$HOME .
