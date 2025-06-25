#!/usr/bin/env sh

hosts=("brumstellar" "anteater" "sleeper")

for host in "${hosts[@]}"; do
  echo "🔨 Building NixOS configuration for: $host"
  nix build ".#nixosConfigurations.${host}.config.system.build.toplevel" || {
    echo "❌ Failed to build $host"
    exit 1
  }
done

echo "✅ All builds completed successfully."
