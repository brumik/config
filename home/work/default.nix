{ username }:
{ pkgs, ... }: {
  home.username = username;
  home.homeDirectory = "/home/" + username;
  home.stateVersion = "24.11";
  programs.home-manager.enable = true;
  home.packages = with pkgs; [
    vscode
    chromium
    slack
    spotify
    bitwarden
    obsidian
    vlc
    todoist-electron
    brave
    google-chrome
    yubioath-flutter
    # to decode jwt tokens
    jwt-cli
    ncspot
  ];

  imports = [
    ../modules/sops.nix
    (import ../modules/terminal { username = "levente"; })
    ../levente/git.nix
    ../levente/gnome.nix
    ../levente/styling.nix
    ../levente/hyprland
  ];
}
