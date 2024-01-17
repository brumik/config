{ pkgs, ... }:
{
  home.packages = [
    pkgs.alacritty
  ];

  home.file.".config/alacritty/alacritty.yml".source = ./alacritty.yml;
}
