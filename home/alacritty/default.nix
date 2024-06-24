{ pkgs, ... }:
{
  home.packages = [
    pkgs.alacritty
  ];

  home.file.".config/alacritty/alacritty.toml".source = ./alacritty.toml;
}
