{ pkgs, ... }:
{
  programs.kitty = {
    enable = true;
    package = pkgs.unstable.kitty;
    shellIntegration.enableZshIntegration = true;
    settings = {
      hide_window_decorations = true;
    };
  };
  programs.alacritty = {
    enable = true;
    settings = {
      font.offset = {
        x = 0;
        y = 0;
      };
      window = {
        decorations = "None";
        dynamic_padding = true;
        padding.x = 5;
        padding.y = 0;
      }; 
    };
  };
}
