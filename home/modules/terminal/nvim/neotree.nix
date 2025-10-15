{ ... }:

{
  programs.nixvim = {
    keymaps = [
      {
        action = "<cmd>Neotree float toggle reveal<CR>";
        key = "<leader>n";
        mode = [ "n" ];
        options.desc = "Toggle tree view";
      }
    ];

    plugins.neo-tree = {
      enable = true;
      settings = {
        closeIfLastWindow = true;
        popupBorderStyle = "rounded";
        filesystem.filteredItems.visible = true;
      };
    };
  };
}
