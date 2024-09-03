{ pkgs, ... }: let username = "katerina"; in {
  home.username = username;
  home.homeDirectory = "/home/" + username;
  home.stateVersion = "23.11";
  programs.home-manager.enable = true;
  home.packages = with pkgs; [
    firefox
    unstable.spotify
    todoist
    signal-desktop
    bitwarden
    telegram-desktop
    onlyoffice-bin
    chromium
    unstable.synology-drive-client
    anki-bin
    unstable.protonvpn-gui
    virt-viewer
  ];

  imports = [
    ../modules/terminal
    ../modules/spotdl
    # Local
    ./gnome.nix
    ./styling.nix
  ];
}
