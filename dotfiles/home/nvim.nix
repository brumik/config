{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    # defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    plugins = [
      pkgs.vimPlugins.nvim-treesitter.withAllGrammars
    ];
  };
  
  # We maintain our custom config without putting nix in it.
  # However adding a new file will cause this to not recompile.
  # Recommended when playing with it to link it with ln -s and 
  # when done commit it to git and rebuild nix
  home.file."./.config/nvim/" = {
    source = ./nvim;
    recursive = true;
  };

  # Treesitter is configured as a locally developed module in lazy.nvim
  # we hardcode a symlink here so that we can refer to it in our lazy config
  home.file."./.local/share/nvim/nix/nvim-treesitter/" = {
    recursive = true;
    source = pkgs.vimPlugins.nvim-treesitter.withAllGrammars;
  };
 
  # These packages are needed for manson and nvchad
  # home.packages = with pkgs; [
    # ripgrep
    # unzip
    # nodejs
    # gnumake
    # gcc
    # cargo
  # ];
}
