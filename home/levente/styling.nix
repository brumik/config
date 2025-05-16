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
  imports = [ ./hyprland ];

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
}
