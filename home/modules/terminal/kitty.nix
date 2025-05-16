{ ... }: {
  programs.kitty = {
    enable = true;
    themeFile = "everforest_dark_hard";
    shellIntegration.enableZshIntegration = true;
    settings = {
      hide_window_decorations = true;
    };
  };
}
