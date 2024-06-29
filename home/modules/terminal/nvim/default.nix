{ pkgs, inputs, ... }:

{
  imports = [
    inputs.nixvim.homeManagerModules.nixvim
    ./lsp.nix
    # ./neotree.nix
    ./oil.nix
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

    opts = {
      expandtab = true;
      tabstop = 2;
      shiftwidth = 2;
      number = true;
      scrolloff = 10;
      termguicolors = true;
      smartindent = true;
      cursorline = true;
      # disables fold on file open (zc enables it again)
      foldenable = false;
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
      nix.enable = true;
      lualine.enable = true;
      treesitter = {
        enable = true;
        indent = true;
        folding = true;
      };
      tmux-navigator = {
        enable = true;
        settings.save_on_switch = 1;
      };
      which-key.enable = true;
    };
  };
}
