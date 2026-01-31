#!/usr/env sh

# Run opencode in docker

# Build and start the container
docker compose -f /home/levente/config/non-nix/opencode-workspace/docker-compose.yml up -d

# Execute opencode in the container
docker compose -f /home/levente/config/non-nix/opencode-workspace/docker-compose.yml exec opencode opencode