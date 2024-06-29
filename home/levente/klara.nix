{ pkgs, ... }: {
  home.packages = with pkgs; [
    unstable.devbox
    unstable.vscode
    unstable.insomnia
    chromium-dev
    unstable.slack
    docker-compose
    # unstable.android-studio
  ];
}
