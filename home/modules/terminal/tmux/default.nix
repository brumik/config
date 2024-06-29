{ pkgs, ... }: {
  home.packages = [
    pkgs.unstable.tmux-sessionizer
  ];
  home.file.".config/tms/config.toml".source = ./default-config.toml;

  programs.tmux = {
    enable = true;
    plugins = with pkgs; [
      {
        plugin = tmuxPlugins.catppuccin;
        extraConfig = '' 
          set -g @catppuccin_flavour 'frappe'
          set -g @catppuccin_window_default_text "#W" 
        ''; 
      }
      tmuxPlugins.vim-tmux-navigator
    ];
    baseIndex = 1;
    keyMode = "vi";
    mouse = true;
    prefix = "C-a";
    extraConfig = ''
      set -g default-terminal "$TERM"
      set -ag terminal-overrides ",$TERM:Tc"

      # custom commands
      bind C-a display-popup -E "tms switch"
      bind C-o display-popup -E "tms"
      bind C-q display-popup -h 91% -w 75% -E "ollama run mistral" 

      # styling
      set -g status-position top
      set -g status-left-length 20
    '';
  };
}
