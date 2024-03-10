{ pkgs, ... }:

{
  home.packages = [
    pkgs.qmk
  ];

  home.file.".config/qmk/qmk.ini".source = ./qmk.ini;
}
