{ ... }:
{
  programs.alacritty = {
    enable = true;
    settings = {
      font.offset = {
        x = 0;
        y = 0;
      };
      window = {
        decorations = "None";
        dynamic_padding = true;
        padding.x = 5;
        padding.y = 0;
      }; 
    };
  };
}
