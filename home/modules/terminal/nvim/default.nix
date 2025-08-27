{ pkgs, inputs, ... }:

{
  imports = [
    inputs.nixvim.homeModules.nixvim
    ./lsp.nix
    ./neotree.nix
    # ./oil.nix
    ./telescope.nix
    ./comment.nix
    ./harpoon.nix
    ./codecompanion.nix
    ./markdown.nix
    # ./flash.nix
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  home.packages = with pkgs; [
    # clipboard provider for wayland
    wl-clipboard
    # clipboard providre for xorg
    xclip


    ripgrep # for telescope
    fd # for telescope
    fzf # for telescope
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
        settings = { indent.enable = true; };
        folding = true;
      };
      tmux-navigator = {
        enable = true;
        settings.save_on_switch = 1;
      };
      gitsigns = {
        enable = true;
        settings = {
          current_line_blame_opts.delay = 0;
          current_line_blame = true;
        };
      };
      which-key.enable = true;
      # Required by plugins, needs explicit from 24.11
      web-devicons.enable = true;
    };
  };
}
