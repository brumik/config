{ pkgs, username, ... }: {
  home.username = username;
  home.homeDirectory = "/home/" + username;
  home.stateVersion = "23.11";
  programs.home-manager.enable = true;
  home.packages = with pkgs; [
    firefox
    spotify
    signal-desktop
    unstable.obsidian
    bitwarden
    onlyoffice-bin
    vlc
    transmission_4-qt
    jellyfin-media-player
    ytsum
    element-desktop
    amber
 ];

  imports = [
    ../nvim
    ../alacritty
    ../gnome/levente.nix
    ../tmux
    ../git
    ../klara.nix
    ../zsh.nix
    ../spotdl
    ../qmk
    ../bw-setup-secrets
  ];
}
