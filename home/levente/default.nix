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
  ];

  imports = [
    (import ../modules/terminal { inherit username; })
    ../modules/spotdl
    ../modules/qmk
    (import ../modules/bw-setup-secrets { inherit username; })
    # Local
    ./gnome.nix
    ./styling.nix
  ];
}
