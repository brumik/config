{ username }: { pkgs, ... }: {
  home.username = username;
  home.homeDirectory = "/home/" + username;
  home.stateVersion = "24.05";
  programs.home-manager.enable = true;
  home.packages = with pkgs; [
    unstable.firefox
    unstable.brave
    spotify
    vlc
    zen-browser
  ];

  imports = [
    ../levente/gnome.nix
    ../levente/styling.nix
  ];
}
