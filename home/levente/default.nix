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
    transmission_4-qt
    element-desktop
    todoist-electron
    yubioath-flutter
    brave
    nextcloud-client
    ncspot
  ];

  services.nextcloud-client = {
    enable = true;
    startInBackground = true;
  };

  imports = [
    ../modules/sops.nix
    (import ../modules/terminal { inherit username; })
    ../modules/spotdl
    ../modules/qmk
    # Local
    ./git.nix
    ./gnome.nix
    ./styling.nix
    ./hyprland
  ];
}
