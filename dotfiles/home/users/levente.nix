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
  ];

  imports = [
    ../nvim.nix
    ../alacritty/default.nix
    ../gnome/levente.nix
    ../tmux.nix
    ../git/default.nix
    ../klara.nix
    ../zsh.nix
  ];
}
