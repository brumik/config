{ pkgs, ... }: {
  # Default stylix
  stylix = {
    enable = true;
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    image = ../../assets/wallpapers/anteater-3360x2240.jpg;

    fonts = {
      monospace = {
        # we might neet to clear font cache when using this:
        # https://github.com/NixOS/nixpkgs/issues/57780
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono";
      };
      sansSerif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Sans";
      };
      serif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Serif";
      };
    };

    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 24;
    };

    fonts.sizes = {
      terminal = 10;
      applications = 10;
      desktop = 10;
      popups = 10;
    };
  };
}
