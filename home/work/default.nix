{ username }: { pkgs, ... }: {
  home.username = username;
  home.homeDirectory = "/home/" + username;
  home.stateVersion = "24.05";
  programs.home-manager.enable = true;
  home.packages = with pkgs; [
    unstable.vscode
    chromium
    unstable.slack
    spotify
    bitwarden
    unstable.obsidian
    vlc
    unstable.todoist-electron
    unstable.brave
  ];

  imports = [
    (import ../modules/terminal { username = "levente"; })
    (import ../modules/bw-setup-secrets { username = "levente"; })
    ../levente/gnome.nix
    ../levente/styling.nix
  ];
}
