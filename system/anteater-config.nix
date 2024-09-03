{ pkgs, ... }:
{
  imports = [
    ./hardware/anteater.nix
    ./modules/base-configuration.nix
  ];

  networking.hostName = "nixos-katerina";

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; 
  };

  # Use grub for syling, als HW config needs to change if removed

  # Styling
  boot.loader = {
    systemd-boot = {
      enable = pkgs.lib.mkForce false;
    };
    grub = {
      enable = true;
      device = "/dev/sda";
      gfxmodeEfi = "1920x1080,auto";
      gfxmodeBios = "1920x1080,auto";
      fontSize = 36;
    };
  };

  stylix = {
    enable = true;
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-frappe.yaml";
    image = ../wallpapers/anteater-3360x2240.jpg;

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
