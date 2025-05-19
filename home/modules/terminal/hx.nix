{ pkgs, ... }: {
  programs.helix = {
    enable = true;
    extraPackages = with pkgs; [
      vscode-langservers-extracted
      nixd
      typescript-language-server
      ruby-lsp
      solargraph
    ];
    settings = { theme = "everforest_dark"; };
  };
}
