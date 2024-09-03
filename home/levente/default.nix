{ username }: { pkgs, ... }: {
  home.username = username;
  home.homeDirectory = "/home/" + username;
  home.stateVersion = "24.05";
  programs.home-manager.enable = true;
  home.packages = with pkgs; [
    firefox
    spotify
    signal-desktop
    unstable.obsidian
    bitwarden
    onlyoffice-bin
    vlc
    transmission_4-qt
    jellyfin-media-player
    ytsum
    element-desktop
    brave
  ];

  imports = [
    ../modules/terminal
    ../modules/spotdl
    ../modules/qmk
    # Local
    ./gnome.nix
    (import ./bw-setup-secrets { inherit username; })
    ./klara.nix
    ./styling.nix
  ];

  # Styling
  stylix = {
    enable = true;
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    image = ../../wallpapers/catppuccin-sports-5120x1440.png;

    fonts = { 
      monospace = {
        package = pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; };
        name = "JetBrainsMono Nerd Font";
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
      terminal = 14;
      applications = 10;
      desktop = 10;
      popups = 10;
    };
  };
}
