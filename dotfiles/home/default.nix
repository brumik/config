{ pkgs, ... }: {
  home.username = "levente";
  home.homeDirectory = "/home/levente";
  home.stateVersion = "22.11";
  programs.home-manager.enable = true;
  home.packages = with pkgs; [
    firefox
    spotify
    discord
    todoist
    signal-desktop
    unstable.obsidian
    bitwarden
  ];

  imports = [
    ./nvim.nix
    ./alacritty/default.nix
    ./gnome/default.nix
    ./tmux.nix
    ./git/default.nix
    ./klara.nix
    ./zsh.nix
  ];

 }
