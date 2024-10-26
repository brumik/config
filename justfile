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

# clean old generations
clean:
  nix-collect-garbage -d
