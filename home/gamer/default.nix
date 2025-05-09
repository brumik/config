{ username }: { pkgs, ... }: {
  home.username = username;
  home.homeDirectory = "/home/" + username;
  home.stateVersion = "24.11";
  programs.home-manager.enable = true;
  home.packages = with pkgs; [
    firefox
    brave
    spotify
    vlc
    zen-browser
  ];

  imports = [
    ../levente/gnome.nix
    ../levente/styling.nix
  ];
}
