#!/usr/bin/env zsh

nix-runner() {
  nix run "nixpkgs#$1" -- "${@:2}"
}

nix-runner $@
