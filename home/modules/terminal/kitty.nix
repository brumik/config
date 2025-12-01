{ ... }: {
  programs.kitty = {
    enable = true;
    shellIntegration.enableZshIntegration = true;
    settings = {
      hide_window_decorations = true;
    };
  };

  home.sessionVariables = {
    # TERMINAL = "kitty";
  };

  # programs.zsh.shellAliases = {
  #   ssh = "kitten ssh";
  # };
}
