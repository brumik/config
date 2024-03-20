{ pkgs, ... }: {
  home.username = "levente";
  home.homeDirectory = "/home/levente";
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
    unstable.protonvpn-gui
    bw-setup-secrets
    vlc
    jellyfin-media-player
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
