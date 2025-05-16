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
    brave
    todoist-electron
    yubioath-flutter
    waybar
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
    padding = 10;
    margin = "20 10 0 10";
  };

  # Getting elevated permissions.
  # TODO: It seems it is using a different polkit agent for now
  # Make sure that if you disable gnome it still works
  # `pkexec bash` this should not say "Authorization required, bot no Authorization protocol specified"
  # services.hyprpolkitagent.enable = true;

  # Top bar
  # There is a pacakge too but only installing the waybar is enough for now

  # Wallpaper
  # TODO: does not work for some reason (seems like not installing hyprpaper
  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "on";
      peload = [ "/home/levente/config/assets/wallpapers/everforest-original.png" ];
      wallpaper = [ ",/home/levente/config/assets/wallpapers/everforest-original.png" ];
    };
  };

  # App lancher
  programs.wofi = { enable = true; };

  # allow music controlls
  services.playerctld.enable = true;
  # allow copy history
  services.cliphist.enable = true;
  # allow browser
  programs.qutebrowser = { enable = true; };
}
