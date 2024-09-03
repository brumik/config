{ pkgs, ... }: let username = "levente"; in {
  home.username = username;
  home.homeDirectory = "/home/" + username;
  home.stateVersion = "24.05";
  programs.home-manager.enable = true;
  home.packages = with pkgs; [
    firefox
    spotify
    signal-desktop
    unstable.obsidian
    bitwarden
    onlyoffice-bin
    vlc
    transmission_4-qt
    jellyfin-media-player
    ytsum
    element-desktop
 ];

  imports = [
    ../modules/terminal
    ../modules/spotdl
    ../modules/qmk
    # Local
    ./gnome.nix
    ( import ./bw-setup-secrets { inherit pkgs username; })
    ./klara.nix
    ./styling.nix
  ];
}
