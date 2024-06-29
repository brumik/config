{ ... }:

{
  programs.nixvim = {
    keymaps = [ 
      {
        action = "<cmd>lua require('flash').jump()<cr>";
        key = "s";
        mode = [ "n" ];
        options.desc = "Flash jump";
      }
      {
        action = "<cmd>lua require('flash').treesitter()<cr>";
        key = "S";
        mode = [ "n" ];
        options.desc = "Flash jump treesitter";
      }
    ];

    plugins = { 
      flash.enable = true;
    };
  };
}
