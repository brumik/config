{ pkgs, ... }:
let
  everforest = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "everforest";
    # postInstall = ''
    #   sed -i -e 's|''${PLUGIN_DIR}/everforest-dark-hard.tmuxtheme|''${TMUX_TMPDIR}/everforest-dark-hard.tmuxtheme|g' $target/everforest.tmux
    # '';
    version = "1.0";
    src = pkgs.fetchFromGitHub {
      owner = "donwlewis";
      repo = "everforest-tmux";
      rev = "main"; # or a specific commit hash
      sha256 =
        "sha256-d3PdA+OxgIgwRJcBykYR+bKmWVepM0ValwLfLBflLeI="; # replace with real hash
    };
  };
in {

  stylix.targets = {
    kitty.enable = false;
    vim.enable = false;
    tmux.enable = false;
  };

  # Nvim
  programs.nixvim.colorschemes.everforest = {
    enable = true;
    settings.background = "hard";
  };

  # kitty
  programs.kitty.themeFile = "everforest_dark_hard";

  programs.tmux = {
    plugins = [ everforest ];
  };

  # Style the diffnav set as default pager for git
  programs.git.settings.delta.syntax-theme = "base16-stylix";
}
