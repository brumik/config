{ pkgs, ... }: {
  home.packages = with pkgs; [
    unstable.vscode
    unstable.insomnia
    chromium
    unstable.slack
    docker-compose
  ];
}
