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
Check if the name is the same in `.gitconfig` where specifies the `user.signingkey`
