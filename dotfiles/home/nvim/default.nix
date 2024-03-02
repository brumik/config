{ pkgs, inputs, ... }:

{
  imports = [
    inputs.nixvim.homeManagerModules.nixvim
    ./theme.nix
    ./lsp.nix
    ./neotree.nix
    ./telescope.nix
  ];


  home.packages = with pkgs; [
    wl-clipboard
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
      {
        action = "vim.lsp.buf.format";
        key = "<leader>fm";
        lua = true;
        mode = [ "n" ];
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
      none-ls = {
        enable = true;
        sources = {
          formatting = {
            prettier.enable = true;
            stylua.enable = true;
          };
        };
      };
    };
  };
}
