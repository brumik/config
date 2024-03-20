{ pkgs, ... }:

{
  home.packages = [
    pkgs.git
    pkgs.lazygit
  ];

  home.file.".gitconfig".source = ./.gitconfig;
}
