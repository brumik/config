{ pkgs, ... }:

{
  home.packages = [ 
    pkgs.spotdl
  ];

  home.file.".spotdl/config.json".source = ./config.json;
}
