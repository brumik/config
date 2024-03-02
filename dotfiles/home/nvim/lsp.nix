{ ... }:

{
  programs.nixvim = {
    keymaps = [
      {
        action = "vim.lsp.buf.format";
        key = "<leader>fm";
        lua = true;
        mode = [ "n" ];
        options.desc = "Format file";
      }
    ];
    plugins = { 
      lsp = {
        enable = true;
        servers = {
          nil_ls.enable = true; 
          gopls.enable = true;
          tsserver.enable = true;
        };
      };
      none-ls = {
        enable = true;
        sources = {
          formatting = {
            prettier.enable = true;
            stylua.enable = true;
            gofmt.enable = true;
          };
          diagnostics = {
            eslint_d.enable = true;
          };
        };
      };
      cmp-nvim-lsp.enable = true;
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
        mapping = {
          "<C-y>" = "cmp.mapping.confirm({ select = true })";
          "<C-n>" = {
            action = ''
              function(fallback)
                if cmp.visible() then
                  cmp.select_next_item()
                else
                  fallback()
                end
              end
            '';
            modes = ["i" "s"];
          };
          "<C-p>" = {
            action = ''
              function(fallback)
                if cmp.visible() then
                  cmp.select_prev_item()
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
