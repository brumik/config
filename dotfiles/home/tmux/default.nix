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

      bind C-o display-popup -E "tms"
    '';
  };
}
