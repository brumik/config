{ pkgs, ... }:

{
  home.packages = with pkgs; [
    lua54Packages.jsregexp
  ];
  programs.nixvim = {
    keymaps = [
      {
        action = "vim.lsp.buf.format";
        key = "<leader>fm";
        lua = true;
        mode = [ "n" ];
        options.desc = "Format file";
      }
      {
        action = "vim.diagnostic.open_float";
        key = "<leader>e";
        lua = true;
        mode = [ "n" ];
        options.desc = "Open floating errors";
      }
      {
        action = "vim.diagnostic.goto_prev";
        key = "<leader>k";
        lua = true;
        mode = [ "n" ];
        options.desc = "Go to prev error";
      }
      {
        action = "vim.diagnostic.goto_next";
        key = "<leader>j";
        lua = true;
        mode = [ "n" ];
        options.desc = "Go to next error";
      }
      {
        action = "vim.lsp.buf.hover";
        key = "K";
        lua = true;
        mode = [ "n" ];
        options.desc = "Hover";
      }
      {
        action = "vim.lsp.buf.declaration";
        key = "gD";
        lua = true;
        mode = [ "n" ];
        options.desc = "Go to declaration";
      }
      {
        action = "vim.lsp.buf.definition";
        key = "gd";
        lua = true;
        mode = [ "n" ];
        options.desc = "Go to definition";
      }
      {
        action = "vim.lsp.buf.references";
        key = "gr";
        lua = true;
        mode = [ "n" ];
        options.desc = "Search for references";
      }
      {
        action = "vim.lsp.buf.rename";
        key = "<leader>rn";
        lua = true;
        mode = [ "n" ];
        options.desc = "Rename variable in buffer";
      }
      {
        action = "vim.lsp.buf.code_action";
        key = "<leader>ca";
        lua = true;
        mode = [ "n" "v" ];
        options.desc = "Code action";
      }
 
    ];
    plugins = { 
      lsp = {
        enable = true;
        servers = {
          nil_ls.enable = true; # nix
          gopls.enable = true; # go
          tsserver.enable = true; # ts
          pyright.enable = true; # python
          rust-analyzer = { # rust
            enable = true;
            package = pkgs.unstable.rust-analyzer;
            ## expect rust installed in projects where I need it (:
            installCargo = false;
            installRustc = false;
          };
        };
      };
      none-ls = {
        enable = true;
        sources = {
          formatting = {
            black.enable = true; # python
            prettier.enable = true; # js
            stylua.enable = true; # lua
            gofmt.enable = true; # go
          };
          diagnostics = {
            eslint_d.enable = true;
          };
        };
      };
      cmp-nvim-lsp.enable = true;
      # we need a snipet engine to avoid crashing vim when language server sends snippets
      luasnip.enable = true;
      cmp_luasnip.enable = true;
      nvim-cmp = {
        enable = true;
        autoEnableSources = true;
        completion.completeopt = "menu,menuone,noisert,select";
        sources = [
          {name = "nvim_lsp";}
          {name = "path";}
          {name = "buffer";}
          {name = "luasnip";}
        ];
        snippet = {
          expand = "luasnip";
        };
        mapping = {
          "<C-y>" = "cmp.mapping.confirm({ select = true })";
          "<C-n>" = {
            action = ''
              function(fallback)
                if cmp.visible() then
                  cmp.select_next_item()
                elseif luasnip.expand_or_jumpable() then
                    luasnip.expand_or_jump()
                elseif has_words_before() then
                    cmp.complete()
                else
                  fallback()
                end
              end
            '';
            modes = ["i" "s"];
          };
          "<M-C-n>" = {
            action = ''
              function(fallback)
                if cmp.visible() then
                  cmp.select_prev_item()
                elseif luasnip.jumpable(-1) then
                  luasnip.jump(-1)
                else
                  fallback()
                end
              end
            '';
            modes = ["i" "s"];
          };
        };
      };
    };
  };
}
