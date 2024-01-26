{ pkgs, ... }: {
  home.username = "levente";
  home.homeDirectory = "/home/levente";
  home.stateVersion = "22.11";
  programs.home-manager.enable = true;
  home.packages = with pkgs; [
    firefox
    microsoft-edge
    spotify
    discord
    slack
    todoist
    signal-desktop
    unstable.obsidian
    bitwarden
  ];

  imports = [
    ./nvim/default.nix
    ./hyprland/default.nix
    ./alacritty/default.nix
  ];

  # for setting up terminal
  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "robbyrussell";
    };
  };
 
  programs.tmux = {
    enable = true;
    plugins = with pkgs; [
      tmuxPlugins.nord
      tmuxPlugins.sensible
      tmuxPlugins.vim-tmux-navigator
    ];
    extraConfig = ''
      set -g default-terminal "$TERM"
      set -ag terminal-overrides ",$TERM:Tc"
      set -g mouse on
    '';
  };
  
  home.file.".gitconfig".source = ./git/.gitconfig;
}
