{ pkgs, ... }: {
  home.packages = with pkgs; [
    vscode
    chromium
    slack
    docker-compose
  ];
}
