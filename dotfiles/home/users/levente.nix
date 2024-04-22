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
    synology-drive-client
    bw-setup-secrets
    vlc
    transmission_4-qt
    jellyfin-media-player
    ytsum
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
  ];
}
