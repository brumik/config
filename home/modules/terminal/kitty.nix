{ pkgs, ... }: {
  programs.kitty = {
    enable = true;
    package = pkgs.unstable.kitty;
    shellIntegration.enableZshIntegration = true;
    theme = "Catppuccin-Mocha";
    settings = {
      hide_window_decorations = true;
    };
  };
}
