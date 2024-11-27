{ pkgs, ... }: {
  home.packages = [
    pkgs.unstable.tmux-sessionizer
  ];
  home.file.".config/tms/config.toml".source = ./default-config.toml;

  programs.tmux = {
    enable = true;
    plugins = with pkgs; [
      tmuxPlugins.vim-tmux-navigator
    ];
    baseIndex = 1;
    keyMode = "vi";
    mouse = true;
    prefix = "C-a";
    extraConfig = ''
      set -g default-terminal "$TERM"
      set -ag terminal-overrides ",$TERM:Tc"

      # When there is other session running 
      # on exiting the last window in the session open the other one
      # instead of closing the terminal window
      set -g detach-on-destroy off

      # custom commands
      bind C-a display-popup -E "tms switch"
      bind C-o display-popup -E "tms"
      # bind C-q display-popup -h 91% -w 75% -E "ollama run mistral" 

      # styling
      set -g status-position top
      set -g status-left-length 20
    '';
  };

  programs.zsh = {
    oh-my-zsh.plugins = [ "tmux" ];
    envExtra = ''
      # ZSH_TMUX_AUTOSTART=true
      ZSH_TMUX_DEFAULT_SESSION_NAME=home
      ZSH_TMUX_CONFIG=$HOME/.config/tmux/tmux.conf
    '';
  };
}
