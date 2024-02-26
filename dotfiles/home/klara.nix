{ pkgs, ... }: {
  home.packages = with pkgs; [
    chromium
    slack
    docker-compose
  ];
}
