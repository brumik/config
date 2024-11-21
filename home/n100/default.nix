{ username }: { ... }: {
  home.username = username;
  home.homeDirectory = "/home/" + username;
  home.stateVersion = "24.05";
  programs.home-manager.enable = true;

  imports = [
    (import ../modules/terminal { username = "levente"; })
    (import ../modules/bw-setup-secrets { username = "levente"; })
    ../modules/styling/tmux-everforest.nix
  ];
}
