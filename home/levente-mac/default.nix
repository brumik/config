{ username }: { ... }: {
  home.username = username;
  home.homeDirectory = "/Users/" + username;
  home.stateVersion = "24.05";
  programs.home-manager.enable = true;

  imports = [
    ../modules/terminal/alacritty
    ../modules/terminal/nvim
    ../modules/terminal/tmux
    ../modules/terminal/zsh
    ../levente/styling.nix
  ];
}
