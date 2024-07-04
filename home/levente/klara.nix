{ pkgs, ... }: {
  home.packages = with pkgs; [
    unstable.devbox
    unstable.vscode
    unstable.insomnia
    chromium
    unstable.slack
    docker-compose
    # unstable.android-studio
  ];
}
