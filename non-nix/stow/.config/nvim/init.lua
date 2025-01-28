require("config.lazy")

local set = vim.opt

-- Set the colorscheme to everforest
vim.cmd([[colorscheme everforest]])
set.background = 'dark'

set.clipboard = 'unnamedplus'
set.expandtab = true
set.tabstop = 2
set.shiftwidth = 2
set.number = true
set.scrolloff = 10
set.termguicolors = true
set.cursorline = true
set.smartindent = true
set.foldenable = false