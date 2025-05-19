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
    waybar.enable = false;
    kitty.enable = false;
    vim.enable = false;
    tmux.enable = false;
    hyprpaper.enable = false;
    hyprland.enable = false;
    gtk.enable = false;
  };

  # Nvim
  programs.nixvim.colorschemes.everforest = {
    enable = true;
    settings.background = "hard";
  };

  # kitty
  programs.kitty.themeFile = "everforest_dark_hard";

  # GTK Apps:
  gtk = {
    theme = {
      name = "Everforest-Dark-BL-LB";
      package = pkgs.everforest-gtk-theme;
    };
  };

  myHome.hyprpaper.wallpaperFile =
    ../../assets/wallpapers/everforest-nixos-3840x2160.jpg;

  programs.tmux = {
    plugins = [ everforest ];
  };

  # Style the diffnav set as default pager for git
  stylix.targets.bat.enable = true;
  programs.git.extraConfig.delta.syntax-theme = "base16-stylix";
}
