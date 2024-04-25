{ pkgs, ... }: {
  home.packages = [
    pkgs.unstable.tmux-sessionizer
  ];
  home.file.".config/tms/config.toml".source = ./default-config.toml;

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

      # remap prefix from 'C-b' to 'C-a'
      unbind C-b
      set-option -g prefix C-a
      bind-key C-a send-prefix

      # custom commands
      bind C-o display-popup -E "tms switch"
      bind C-i display-popup -E "tms"
      bind C-q display-popup -h 91% -w 75% -E "ollama run mistral" 

      # styling
      set -g status-position top
      set -g status-left-length 20
    '';
  };
}
