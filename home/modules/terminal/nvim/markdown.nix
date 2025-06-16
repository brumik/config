{ ... }: {
  programs.nixvim = {
    # treesitter did not started without this
    autoCmd = [{
      event = "FileType";
      pattern = [ "markdown" "codecompanion" ];
      callback = {
        __raw = ''
          function(args)
            vim.treesitter.start(args.buf)
          end
        '';
      };
      desc = "Starting tree sitter manually after opening md files";
    }];

    plugins.render-markdown = {
      enable = true;
      settings = { file_types = [ "markdown" "codecompanion" ]; };
    };
  };
}
