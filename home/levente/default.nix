{ username }: { pkgs, ... }: {
  home.username = username;
  home.homeDirectory = "/home/" + username;
  home.stateVersion = "24.05";
  programs.home-manager.enable = true;
  home.packages = with pkgs; [
    spotify
    signal-desktop
    unstable.obsidian
    bitwarden
    onlyoffice-bin
    vlc
    transmission_4-qt
    element-desktop
    brave
    todoist-electron
    # ytsum
    zen-browser
    yubioath-flutter
  ];

  imports = [
    ../modules/sops.nix
    (import ../modules/terminal { inherit username; })
    ../modules/spotdl
    ../modules/qmk
    # Local
    ./git.nix
    ./gnome.nix
  ];
}
