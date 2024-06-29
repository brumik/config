{ pkgs, ... }:

{
  home.packages = [ 
    pkgs.unstable.spotdl
  ];

  home.file.".spotdl/config.json".source = ./config.json;
}
