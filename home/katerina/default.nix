{ username }: { pkgs, ... }: {
  home.username = username;
  home.homeDirectory = "/home/" + username;
  home.stateVersion = "24.11";
  programs.home-manager.enable = true;
  home.packages = with pkgs; [
    firefox
    signal-desktop
    bitwarden-desktop
    telegram-desktop
    onlyoffice-desktopeditors
    anki-bin
    google-chrome
    obsidian
    spotify
    wasistlos
    brave
    nextcloud-client
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
    # Local
    ./gnome.nix
  ];
}
