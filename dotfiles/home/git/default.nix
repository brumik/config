{ pkgs, ... }:

{
  home.packages = [
    pkgs.git
    pkgs.lazygit
  ];

  home.file.".gitconfig".source = ./.gitconfig;
  home.file.".ssh/config".source = ./config;
}
