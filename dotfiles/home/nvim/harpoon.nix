{ ... }:

{
  programs.nixvim = {
    plugins.harpoon = {
      enable = true;
      keymaps = {
        addFile = "<leader>hm";
        toggleQuickMenu = "<leader>hh";
        navPrev = "<M-C-n>";
        navNext = "<C-n>";
        navFile = {
          "1" = "<leader>ht";
          "2" = "<leader>hs";
          "3" = "<leader>hr";
          "4" = "<leader>ha";
        };
      };
    };
  };
}
