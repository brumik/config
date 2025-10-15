{ username }:
{ pkgs, ... }: {
  home.username = username;
  home.homeDirectory = "/home/" + username;
  home.stateVersion = "24.11";
  programs.home-manager.enable = true;
  home.packages = with pkgs; [
    spotify
    signal-desktop
    obsidian
    vscode
    bitwarden
    onlyoffice-bin
    vlc
    yubioath-flutter
    brave
    nextcloud-client
    ncspot
    protonvpn-gui
  ];

  services.nextcloud-client = {
    enable = true;
    startInBackground = true;
  };

  imports = [
    ../modules/sops.nix
    ../modules/terminal 
    ../modules/spotdl
    ../modules/qmk
    # Local
    ./git.nix
    ./gnome.nix
    ./styling.nix
  ];
}
