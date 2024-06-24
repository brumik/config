{ pkgs, ... }:

{
  home.packages = with pkgs; [
    ripgrep
    fzf
  ];

  programs.nixvim = {
    keymaps = [ 
      {
        action = "<cmd>Telescope find_files hidden=true no_ignore=true<CR>";
        key = "<leader>fa";
        mode = [ "n" ];
        options.desc = "Find in hidden files";
      }
      {
        action = "<cmd>Telescope buffers<CR>";
        key = "<leader>fb";
        mode = [ "n" ];
        options.desc = "Find in open buffers";
      }
      {
        action = "<cmd>Telescope live_grep<CR>";
        key = "<leader>fw";
        mode = [ "n" ];
        options.desc = "Text Search in files";
      }
      {
        action = "<cmd>Telescope find_files<CR>";
        key = "<leader>ff";
        mode = [ "n" ];
        options.desc = "Find in non-hidden files";
      }
    ];

    plugins.which-key.registrations = {
      "<leader>f" = "> Find in (telescope)";
    };

    plugins = {
      telescope = {
        enable = true;
        extensions = {
          fzf-native = {
            enable = true;
            settings = {
              fuzzy = true;
              case_mode = "smart_case";
            };
          };
        };
      };
    };
  };
}
