{ pkgs, inputs, ... }:

{
  imports = [
    inputs.nixvim.homeManagerModules.nixvim
    ./theme.nix
    ./lsp.nix
    ./neotree.nix
    ./telescope.nix
    ./comment.nix
    ./harpoon.nix
  ];


  home.packages = with pkgs; [
    # clipboard provider for wayland
    wl-clipboard
    # clipboard providre for xorg
    xclip
  ];

  programs.nixvim = {
    enable = true;
    viAlias = true;
    vimAlias = true;

    options = {
      expandtab = true;
      tabstop = 2;
      shiftwidth = 2;
      number = true;
      scrolloff = 10;
      termguicolors = true;
      smartindent = true;
      cursorline = true;
    };

    clipboard.register = "unnamedplus";

    globals.mapleader = " ";

    keymaps = [ 
      # Reset search
      {
        action = "<cmd>noh<CR><CR>";
        key = "<esc>";
        mode = [ "n" ];
        options.desc = "Clear search highlight in buffer";
      }
    ];

    plugins = { 
      lualine = {
        enable = true;
      };
      treesitter = {
        enable = true;
        indent = true;
      };
      tmux-navigator = {
        enable = true;
        tmuxNavigatorSaveOnSwitch = 1;
      };
      which-key = {
        enable = true;
      };
    };
  };
}
