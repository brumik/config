{ username }:
{ pkgs, ... }: {
  home.username = username;
  home.homeDirectory = "/home/" + username;
  home.stateVersion = "24.05";
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
  ];

  imports = [
    (import ../modules/terminal { username = "levente"; })
    ../levente/git.nix
    ../levente/gnome.nix
    ../modules/sops.nix
  ];
}
