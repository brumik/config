#!/usr/bin/env sh
set -e

nix flake update
nix flake check
./build.sh

git add .
git commit -m "Automated update and build"
git push
