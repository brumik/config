return {
  'lewis6991/gitsigns.nvim',
  config = function()
    require('gitsigns').setup({
      current_line_blame = true, -- Toggle with `:Gitsigns toggle_current_line_blame`
      current_line_blame_opts = {
        delay = 0,
      },
    })
  end,
}