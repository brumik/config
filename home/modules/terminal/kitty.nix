{ pkgs, ... }: {
  programs.kitty = {
    enable = true;
    package = pkgs.unstable.kitty;
    shellIntegration.enableZshIntegration = true;
    settings = {
      hide_window_decorations = true;
    };
  };
}
