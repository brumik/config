{ pkgs, ... }:
{
  imports = [
    ./hardware/anteater.nix
    ./modules/base-configuration.nix
    ./modules/amdRX570.nix
    ./modules/smb.nix
  ];

  boot.loader = {
    grub = {
      gfxmodeEfi = "1920x1080,auto";
      gfxmodeBios = "1920x1080,auto";
      fontSize = 36;
    };
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  stylix = {
    enable = true;
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
    image = ../home/gnome/wallpaper-katerina.jpg;

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
      package = pkgs.capitaine-cursors-themed;
      name = "Capitaine Cursors (Gruvbox)";
    };

    fonts.sizes = {
      terminal = 14;
      applications = 10;
      desktop = 10;
      popups = 10;
    };
  };
}
