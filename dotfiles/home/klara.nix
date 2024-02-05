{ pkgs, ... }: {
  home.packages = with pkgs; [
    microsoft-edge
    slack
    docker-compose
  ];
}
