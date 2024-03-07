{ pkgs, ... }: {
  home.username = "katerina";
  home.homeDirectory = "/home/katerina";
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
    synology-drive-client
    anki-bin
    protonvpn-ui
  ];

  imports = [
    ../nvim/default.nix
    ../alacritty/default.nix
    ../gnome/katerina.nix
    ../tmux.nix
    ../zsh.nix
  ];
}
