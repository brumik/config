return {
  "shortcuts/no-neck-pain.nvim",
  version = "*",
  config = function()
    require("no-neck-pain").setup({
      width = 120,
      buffers = {
        wo = {
          fillchars = "eob: ",
        },
        colors = { blend = -0.1 },
      },
    })
   
    vim.keymap.set('n', '<leader>c', ':NoNeckPain<CR>')
  end
}
