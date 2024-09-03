{ username }: { pkgs, ... }: {
  home.username = username;
  home.homeDirectory = "/home/" + username;
  home.stateVersion = "24.05";
  programs.home-manager.enable = true;
  home.packages = with pkgs; [
    firefox
    signal-desktop
    bitwarden
    telegram-desktop
    onlyoffice-bin
    anki-bin
  ];

  imports = [
    (import ../modules/terminal { inherit username; })
    ../modules/spotdl
    (import ../modules/bw-setup-secrets { inherit username; })
    # Local
    ./gnome.nix
    ./styling.nix
  ];
}
