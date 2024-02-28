{ pkgs, ... }: {
  home.packages = with pkgs; [
    vscode
    insomnia
    chromium
    slack
    docker-compose
  ];
}
