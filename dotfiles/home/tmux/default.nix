{ pkgs, ... }: {
  home.packages = [
    pkgs.tmux-sessionizer
  ];
  home.file.".config/tms/default-config.toml".source = ./default-config.toml;

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
      set -g window-size largest
      
      # remap prefix from 'C-b' to 'C-a'
      unbind C-b
      set-option -g prefix C-a
      bind-key C-a send-prefix

      # custom commands
      bind C-o display-popup -E "tms"
      bind C-q display-popup -E "ollama run dolphin-mixtral"

      # styling
      set-option -g status-position top
    '';
  };
}
