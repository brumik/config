{ lib, ... }: {
  imports = [
    ./prometheus.nix
    ./loki.nix
    ./grafana.nix
  ];

  options.homelab.monitoring = { enable = lib.mkEnableOption "monitoring"; };
}
