---@type MappingsTable
local M = {}

M.general = {
  n = {
    ["Q"] = { "@q", "Replay @q" },
  },
}

M.nvimtree = {
  n = {
    ["<leader>n"] = { "<cmd> NvimTreeToggle <CR>", "Toggle nvimtree" },
  },
}

M.disabled = {
  n = {
    ["<C-n>"] = "",
    ["<leader>e"] = "",
    ["<leader>th"] = "",
    ["<A-i>"] = "",
    ["<A-v>"] = "",
    ["<A-h>"] = "",
    ["<leader>v"] = "",
    ["<leader>h"] = "",
    ["<leader>x"] = "",
    ["<S-tab>"] = "",
    ["<tab>"] = "",
    ["<leader>pt"] = "",
  },
  x = {
    ["j"] = "",
    ["p"] = "",
    ["k"] = "",
  },
  t = {
    ["i"] = "",
    ["v"] = "",
    ["h"] = "",
    ["<A-i>"] = "",
    ["<A-v>"] = "",
    ["<A-h>"] = "",
    ["<C-x>"] = "",
  },
}

-- more keybinds!

return M
