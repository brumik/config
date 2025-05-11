{ username }: { pkgs, ... }: {
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
    brave
    todoist-electron
    yubioath-flutter
  ];

  imports = [
    ../modules/sops.nix
    (import ../modules/terminal { inherit username; })
    ../modules/spotdl
    ../modules/qmk
    # Local
    ./git.nix
    ./gnome.nix
  ];

  #####################
  # Hyprland configs  #
  #####################

  # Notification daemon
  # Test it with `libnotify` `notify-send "Title" "Body"`
  services.mako = {
    enable = true;
    defaultTimeout = 5000;
    borderRadius = 8;
  };

  # Getting elevated permissions.
  # TODO: It seems it is using a different polkit agent for now
  # Make sure that if you disable gnome it still works
  # `pkexec bash` this should not say "Authorization required, bot no Authorization protocol specified"
  # services.hyprpolkitagent.enable = true;

  # Top bar
  programs.waybar.enable = true;

  # Wallpaper
  # TODO: does not work for some reason (seems like not installing hyprpaper
  # services.hyprpaper = {
  #   enable = true;
  #   settings = {
  #     ipc = "on";
  #     peload = [ "/home/levente/config/assets/wallpapers/everforest-original.png" ];
  #     wallpaper = [ ",/home/levente/config/assets/wallpapers/everforest-original.png" ];
  #   };
  # };

  # App lancher
  programs.wofi = { 
    enable = true;
  };

  # allow music controlls
  services.playerctld.enable = true;
  services.cliphist.enable = true;
  programs.qutebrowser = {
    enable = true;
  };
}
