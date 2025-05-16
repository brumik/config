{ pkgs, ... }: {
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
}
