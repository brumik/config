{ ... }:

{
  programs.nixvim = {
    plugins.which-key.registrations = {
      "<leader>h" = "> Harpoon";
      "<leader>hm" = "Add a file to harpoon";
      "<leader>hh" = "Open harpoon popup";
      "<leader>ht" = "Harpoon jump to 1st";
      "<leader>hs" = "Harpoon jump to 2nd";
      "<leader>hr" = "Harpoon jump to 3rd";
      "<leader>ha" = "Harpoon jump to 4th";
    };
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
