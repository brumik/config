{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };
  
  home.packages = with pkgs; [
    ripgrep
    unzip
    nodejs
    gnumake
    gcc
    cargo
  ];
}
