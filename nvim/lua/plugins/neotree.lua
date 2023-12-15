return {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
      "3rd/image.nvim", 
    },
    config = function()
      require("neo-tree").setup({
        close_if_last_window = true, 
        popup_border_style = "rounded",
      })

      -- Use the ? when opening the sidebar to check for the shortcuts
      vim.keymap.set('n', '<leader>n', ':Neotree float toggle<CR>')
    end
  }
 
