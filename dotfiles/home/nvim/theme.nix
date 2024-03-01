{ pkgs, ... }:

{
  programs.nixvim = {
    extraPlugins = [
      (pkgs.vimUtils.buildVimPlugin {
        name = "onenord";
        src = pkgs.fetchFromGitHub {
            owner = "rmehri01";
            repo = "onenord.nvim";
            rev = "1527c93d7fcaea743f5ad8f1c58b11bbcffb38bc";
            hash = "sha256-RGPznSlskj3ZCTNR+P9A53Ig4bnez8VbggvQygZjtEw=";
        };
      })
    ];

    extraConfigLua = /* lua */ "
      vim.cmd.colorscheme 'onenord'
    ";
  };
}
