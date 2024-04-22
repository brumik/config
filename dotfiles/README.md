# README

## Usage
Set your hostname on your nixos on the first run to whichever profile you are installing then run:

`sudo nixos-rebuild switch --flake .`

or without setting the hostname first:

`sudo nixos-rebuild switch --flake .#nixos-levente`

To update flakes: `nix flake update`

## Github ssh

Make sure you start you ssh agent from the terminal (one time?):
* `eval "$(ssh-agent -s)"`
* `ssh-add -l`

Then make sure that the key is added both as signing key and auth key to github.

**NOTE: Following steps should be taken care of with bitwarden script**


Make sure that the name of the default key is `id_ed25519` and `id_ed25519.pub`. This is what is set for signing in `.gitconfig` and as a default key in `config` for ssh.
To set up completely the ssh signing you need to add to the `~/.ssh/allowed_signers` file `* PUBLIC_KEY_CONTENTS`.
