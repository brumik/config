{ pkgs, ... }:

{
  # Stilyx should handle all the styling but some cases it is not perfect yet 
  programs.tmux = {
    plugins = with pkgs; [
      {
        plugin = tmuxPlugins.catppuccin;
        extraConfig = '' 
          set -g @catppuccin_flavour 'mocha'
          set -g @catppuccin_window_default_text "#W" 
        ''; 
      }
    ];
  };
}
