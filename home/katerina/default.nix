{ username }: { pkgs, ... }: {
  home.username = username;
  home.homeDirectory = "/home/" + username;
  home.stateVersion = "24.11";
  programs.home-manager.enable = true;
  home.packages = with pkgs; [
    firefox
    signal-desktop
    bitwarden
    telegram-desktop
    onlyoffice-bin
    anki-bin
    google-chrome
    obsidian
    spotify
  ];

  imports = [
    ../modules/sops.nix
    (import ../modules/terminal { inherit username; })
    ../modules/spotdl
    # Local
    ./gnome.nix
  ];
}
