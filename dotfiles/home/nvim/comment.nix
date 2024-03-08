{ ... }:

{
  programs.nixvim = {
    # Mappings are
    # gcc = comment line
    # gc = comment selected in visual
    # gb = comment block in visual
    plugins.comment-nvim = {
      enable = true;
    };
  };
}
