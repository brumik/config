return {
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.5',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('telescope').setup {
        pickers = {
          find_files = {
            hidden = true
          }
        }
      }

      local builtin = require('telescope.builtin')

      -- Docs of mapping when it's open: https://github.com/nvim-telescope/telescope.nvim?tab=readme-ov-file#default-mappings
      vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
      vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
      -- vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
    end
  },
  {
    'nvim-telescope/telescope-ui-select.nvim',
    config = function()
      require("telescope").setup {
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown {}
          }
        }
      }
      -- To get ui-select loaded and working with telescope, you need to call
      -- load_extension, somewhere after setup function:
      require("telescope").load_extension("ui-select")
    end
  },
  {
    "Slotos/telescope-lsp-handlers.nvim",
    config = function()
      require('telescope-lsp-handlers').setup()
    end
  }
}
