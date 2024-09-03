{ pkgs, ... }:
{
  imports = [
    ./hardware/n100.nix
    ./modules/base-configuration.nix
    ./modules/docker.nix
    ./modules/smb.nix
    ./modules/monitorcontroll.nix
  ];
  
  networking.hostName = "nixos-n100"; # Define your hostname.
  
  # Styling
  stylix = {
    enable = true;
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    image = ../wallpapers/catppuccin-sports-5120x1440.png;

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
