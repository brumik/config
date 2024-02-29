return {
  'christoomey/vim-tmux-navigator',
  config = function()
    vim.keymap.set('n', 'C-h', ':TmuxNavigateLeft<CR>')
    vim.keymap.set('n', 'C-j', ':TmuxNavigateUp<CR>')
    vim.keymap.set('n', 'C-k', ':TmuxNavigateDown<CR>')
    vim.keymap.set('n', 'C-l', ':TmuxNavigateRight<CR>')
  end
}
