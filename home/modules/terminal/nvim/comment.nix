{ ... }:

{
  programs.nixvim = {
    # Normal mode
    # `gcc` - Toggles the current line using linewise comment
    # `gbc` - Toggles the current line using blockwise comment
    # `[count]gcc` - Toggles the number of line given as a prefix-count using linewise
    # `[count]gbc` - Toggles the number of line given as a prefix-count using blockwise
    # `gc[count]{motion}` - (Op-pending) Toggles the region using linewise comment
    # `gb[count]{motion}` - (Op-pending) Toggles the region using blockwise comment
    # `gco` - Insert comment to the next line and enters INSERT mode
    # `gcO` - Insert comment to the previous line and enters INSERT mode
    # `gcA` - Insert comment to end of the current line and enters INSERT mode
    # Visual mode
    # `gc` - Toggles the region using linewise comment
    # `gb` - Toggles the region using blockwise comment
    plugins.comment = {
      enable = true;
    };
  };
}
