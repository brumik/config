{ ... }: {
  programs.kitty = {
    enable = true;
    shellIntegration.enableZshIntegration = true;
    settings = {
      hide_window_decorations = true;
    };
  };

  programs.zsh.shellAliases = {
    ssh = "kitten ssh";
  };
}
