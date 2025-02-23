{pkgs, ...}: {
  home.packages = with pkgs; [
    lua54Packages.jsregexp
  ];
  programs.nixvim = {
    keymaps = [
      {
        action.__raw = "vim.lsp.buf.format";
        key = "<leader>fm";
        mode = ["n"];
        options.desc = "Format file";
      }
      {
        action.__raw = "vim.diagnostic.open_float";
        key = "<leader>e";
        mode = ["n"];
        options.desc = "Open floating errors";
      }
      {
        action.__raw = "vim.diagnostic.goto_prev";
        key = "<leader>k";
        mode = ["n"];
        options.desc = "Go to prev error";
      }
      {
        action.__raw = "vim.diagnostic.goto_next";
        key = "<leader>j";
        mode = ["n"];
        options.desc = "Go to next error";
      }
      {
        action.__raw = "vim.lsp.buf.hover";
        key = "K";
        mode = ["n"];
        options.desc = "Hover";
      }
      {
        action.__raw = "vim.lsp.buf.declaration";
        key = "gD";
        mode = ["n"];
        options.desc = "Go to declaration";
      }
      {
        action.__raw = "vim.lsp.buf.definition";
        key = "gd";
        mode = ["n"];
        options.desc = "Go to definition";
      }
      {
        action.__raw = "vim.lsp.buf.references";
        key = "gr";
        mode = ["n"];
        options.desc = "Search for references";
      }
      {
        action.__raw = "vim.lsp.buf.rename";
        key = "<leader>rn";
        mode = ["n"];
        options.desc = "Rename variable in buffer";
      }
      {
        action.__raw = "vim.lsp.buf.code_action";
        key = "<leader>ca";
        mode = ["n" "v"];
        options.desc = "Code action";
      }
      {
        action.__raw = "cmp.mapping.confirm({ select = true })";
        key = "<C-y>";
        mode = ["i"];
        options.desc = "Accept selection";
      }
      {
        action.__raw = ''
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
        key = "<C-n>";
        mode = ["i" "s"];
        options.desc = "Select next option";
      }
      {
        action.__raw = ''
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
        key = "<M-C-n>";
        mode = ["i" "s"];
        options.desc = "Select prev option";
      }
    ];
    plugins = {
      lsp = {
        enable = true;
        servers = {
          html.enable = true;
          nixd = {
            enable = true; # nix
            settings = { 
              nixos.expr = "(builtins.getFlake \"/home/levente/config\").inputs.nixpkgs";
              options = {
                nixos.expr = "(builtins.getFlake \"/home/levente/config\").nixosConfigurations.nixos-brumstellar.options";
              };
            };
          };
          gopls.enable = true; # go
          tsserver.enable = true; # ts
          pyright.enable = true; # python
          ruby-lsp.enable = true; # ruby
        };
      };
      none-ls = {
        enable = true;
        sources = {
          formatting = {
            black.enable = true; # python
            stylua.enable = true; # lua
            gofmt.enable = true; # go
            nixfmt.enable = true; # nix
          };
        };
      };
      cmp-nvim-lsp.enable = true;
      # we need a snipet engine to avoid crashing vim when language server sends snippets
      luasnip.enable = true;
      cmp_luasnip.enable = true;
      cmp = {
        enable = true;
        autoEnableSources = true;
        settings = {
          completion.completeopt = "menu,menuone,noisert,select";
          sources = [
            {name = "nvim_lsp";}
            {name = "path";}
            {name = "buffer";}
            {name = "luasnip";}
          ];
          snippet = {
            expand = ''
              function(args)
                require('luasnip').lsp_expand(args.body)
              end
            '';
          };
        };
      };
    };
  };
}
