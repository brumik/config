{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    # defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };
 
  # These packages are needed for manson and nvchad
  home.packages = with pkgs; [
    ripgrep
    unzip
    nodejs
    gnumake
    gcc
    cargo
  ];
}
