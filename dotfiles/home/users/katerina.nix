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
  ];

  imports = [
    ../nvim.nix
    ../alacritty/default.nix
    ../gnome/default.nix
    ../tmux.nix
    ../zsh.nix
  ];
}
