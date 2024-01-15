{ pkgs, ... }: {
  home.username = "levente";
  home.homeDirectory = "/home/levente";
  home.stateVersion = "22.11";
  programs.home-manager.enable = true;

  # for setting up terminal
  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "robbyrussell";
    };
  };
 
  programs.neovim = {
    enable = true;
    defaultEditor = true;
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
    '';
  };
  
  home.file.".gitconfig".source = ./.gitconfig;
  home.file.".config/alacritty/alacritty.yml".source = ./alacritty/alacritty.yml;
}
