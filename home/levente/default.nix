{ username }:
{ pkgs, ... }: {
  home.username = username;
  home.homeDirectory = "/home/" + username;
  home.stateVersion = "24.11";
  programs.home-manager.enable = true;
  home.packages = with pkgs; [
    signal-desktop
    obsidian
    vscode
    onlyoffice-desktopeditors
    vlc
    yubioath-flutter
    brave
    nextcloud-client
    picard
    discord
    moonlight-qt
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
