return {
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.8',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('telescope').setup({})
      require("which-key").add({ { "<leader>f", group = "Telescope" } })
    end,
    keys = {
      { '<leader>fa', '<cmd>Telescope find_files hidden=true no_ignore=true<CR>', desc = 'Find in hidden files'},
      { '<leader>ff', '<cmd>Telescope find_files<CR>', desc = 'Find in non-hidden files'},
      { '<leader>fb', '<cmd>Telescope buffers<CR>', desc = 'Find in buffers'},
      { '<leader>fw', '<cmd>Telescope live_grep<CR>', desc = 'Grep text project wide'},
    }
  },
  {
    -- Requires gcc and make
    'nvim-telescope/telescope-fzf-native.nvim',
    build = 'make',
    config = function()
      require('telescope').load_extension('fzf')
    end
  },
}