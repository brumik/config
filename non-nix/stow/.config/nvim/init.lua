require("config.lazy")

-- Set the colorscheme to everforest
vim.cmd([[colorscheme everforest]])

vim.cmd("set clipboard=unnamedplus")
vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set shiftwidth=2")
vim.cmd("set number")
vim.cmd("set scrolloff=10")
vim.cmd("set termguicolors")
vim.cmd("set cursorline")
vim.cmd("set smartindent")
vim.cmd("set foldenable!")

-- keymap to clear search higlight
vim.keymap.set('n', '<esc>', "<cmd>noh<CR><CR>", { desc = "Clear search highlight" })