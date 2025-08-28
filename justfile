# default command to list other commands
default:
  @just --list

# rebuild current system
rebuild:
  sudo nixos-rebuild switch --flake .

# Create a age key from current machines ssh key (openssh needs to be enabled)
sops-ssh-to-age:
  nix-shell -p ssh-to-age --run 'cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age'

# This is the command to add or edit secrets in human readable form
sops-edit:
  EDITOR=nvim sops secrets.yaml

# Updating secrets after editing .sops.yml
sops-update:
  nix-shell -p sops --run "sops updatekeys secrets.yaml"

deploy ARG="brumstellar":
  sudo nixos-rebuild switch --flake .#{{ARG}} --target-host root@{{ARG}}.berky.me 

# Restore symlinks with stow (and simple script)
stow-mac:
  ./non-nix/stow/install.sh
  stow --dir=$(pwd)/non-nix/stow --target=$HOME .

# Build a bootable iso image outputted to ./result
build-live-iso:
  nix build .#nixosConfigurations.nixos-live.config.system.build.isoImage

# Generate an OICD key pair for setting up a new client
server-authelia-generate-oicd:
  docker run --rm authelia/authelia:latest authelia crypto hash generate pbkdf2 --variant sha512 --random --random.length 72 --random.charset rfc3986
