{ ... }:

{
  programs.nixvim = {
    plugins.which-key.settings.spec = [
      { __unkeyed = "<leader>h"; desc = "> Harpoon"; group = true; }
      { __unkeyed = "<leader>hm"; desc = "Add a file to harpoon"; }
      { __unkeyed = "<leader>hh"; desc = "Open harpoon popup"; }
      { __unkeyed = "<leader>ht"; desc = "Harpoon jump to 1st"; }
      { __unkeyed = "<leader>hs"; desc = "Harpoon jump to 2nd"; }
      { __unkeyed = "<leader>hr"; desc = "Harpoon jump to 3rd"; }
      { __unkeyed = "<leader>ha"; desc = "Harpoon jump to 4th"; }
    ];
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
