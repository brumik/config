{ pkgs, username, ... }: {
  home.username = username;
  home.homeDirectory = "/home/" + username;
  home.stateVersion = "23.11";
  programs.home-manager.enable = true;
  home.packages = with pkgs; [
    firefox
    spotify
    todoist
    signal-desktop
    bitwarden
    telegram-desktop
    onlyoffice-bin
    google-chrome
    unstable.synology-drive-client
    anki-bin
    unstable.protonvpn-gui
  ];

  imports = [
    ../nvim
    ../alacritty
    ../gnome/katerina.nix
    ../tmux
    ../zsh
  ];
}
