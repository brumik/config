{ pkgs, ... }: {
  programs.kitty = {
    enable = true;
    package = pkgs.kitty;
    shellIntegration.enableZshIntegration = true;
    settings = {
      hide_window_decorations = true;
    };
  };
}
