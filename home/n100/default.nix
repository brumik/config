{ username }: { pkgs, ... }: {
  home.username = username;
  home.homeDirectory = "/home/" + username;
  home.stateVersion = "24.05";
  programs.home-manager.enable = true;

  home.packages = [
    pkgs.just
  ];

  imports = [
    (import ../modules/terminal/git { username = "levente"; })
    ../modules/terminal/zsh
    ../modules/terminal/nvim
    ../modules/terminal/kitty.nix
    ../modules/terminal/tmux
  ];
}
