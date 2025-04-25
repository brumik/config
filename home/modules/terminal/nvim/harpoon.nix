{ ... }:

{
  programs.nixvim = {
    plugins.which-key.settings.spec = [{
      __unkeyed = "<leader>h";
      desc = "> Harpoon";
      group = true;
    }];

    keymaps = [
      {
        mode = "n";
        key = "<leader>hm";
        action.__raw = "function() require'harpoon':list():add() end";
        options.desc = "Add file to harpoon";
      }
      {
        mode = "n";
        key = "<leader>hh";
        action.__raw =
          "function() require'harpoon'.ui:toggle_quick_menu(require'harpoon':list()) end";
        options.desc = "Open harpoon popup";
      }
      {
        mode = "n";
        key = "<leader>ht";
        action.__raw = "function() require'harpoon':list():select(1) end";
        options.desc = "Harpoon jump to 1st";
      }
      {
        mode = "n";
        key = "<leader>hs";
        action.__raw = "function() require'harpoon':list():select(2) end";
        options.desc = "Harpoon jump to 2nd";
      }
      {
        mode = "n";
        key = "<leader>hr";
        action.__raw = "function() require'harpoon':list():select(3) end";
        options.desc = "Harpoon jump to 3rd";
      }
      {
        mode = "n";
        key = "<leader>ha";
        action.__raw = "function() require'harpoon':list():select(4) end";
        options.desc = "Harpoon jump to 4th";
      }
    ];

    plugins.harpoon = {
      enable = true;
    };
  };
}
