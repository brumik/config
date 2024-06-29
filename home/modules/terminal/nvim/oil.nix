{ ... }:

{
  programs.nixvim = {
    keymaps = [
      {
        action = "<cmd>Oil<CR>";
        key = "-";
        mode = [ "n" ];
        options.desc = "Move to the parent directory";
      }
    ];

    plugins.oil = {
      enable = true;
      settings = {
        view_options = {
          show_hidden = true;
        };
        default_file_explorer = true;
      };
    };
  };
}
