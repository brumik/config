{ pkgs, ... }: {
  # Default stylix
  # fonts.fonts = pkgs.nerd-fonts.jetbrains-mono;

  fonts.packages = with pkgs; [ nerd-fonts.jetbrains-mono ];

  # Optional: set fontconfig defaults
  fonts.fontconfig.defaultFonts = {
    monospace = [ "JetBrains Mono" ];
    sansSerif = [ "JetBrains Mono" ];
    serif = [ "JetBrains Mono" ];
  };

  programs.chromium.extraOpts.BrowserThemeColor = "#2b3339";

  # stylix = {
  #   enable = false;
  #   polarity = "dark";
  #   base16Scheme = "${pkgs.base16-schemes}/share/themes/everforest.yaml";
  #   image = ../../assets/wallpapers/everforest-5120x1440.png;
  #
  #   fonts = {
  #     monospace = {
  #       # we might neet to clear font cache when using this:
  #       # https://github.com/NixOS/nixpkgs/issues/57780
  #       package = pkgs.nerd-fonts.jetbrains-mono;
  #       name = "JetBrainsMono";
  #     };
  #     sansSerif = {
  #       package = pkgs.dejavu_fonts;
  #       name = "DejaVu Sans";
  #     };
  #     serif = {
  #       package = pkgs.dejavu_fonts;
  #       name = "DejaVu Serif";
  #     };
  #   };
  #
  #   cursor = {
  #     package = pkgs.bibata-cursors;
  #     name = "Bibata-Modern-Ice";
  #     size = 24;
  #   };
  #
  #   fonts.sizes = {
  #     terminal = 10;
  #     applications = 10;
  #     desktop = 10;
  #     popups = 10;
  #   };
  # };
}
