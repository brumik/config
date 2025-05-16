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
  ];

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

  myHome.hyprpaper.enable = true;
  myHome.waybar.enable = true;

  #####################
  # Hyprland configs  #
  #####################

  # Notification daemon
  # Test it with `libnotify` `notify-send "Title" "Body"`
  services.mako = {
    enable = true;
    settings = {
      default-timeout = 5000;
      border-radius = 8;
      padding = 10;
      outer-margin = 20;
    };
  };

  # Getting elevated permissions.
  # TODO: It seems it is using a different polkit agent for now
  # Make sure that if you disable gnome it still works
  # `pkexec bash` this should not say "Authorization required, bot no Authorization protocol specified"
  # services.hyprpolkitagent.enable = true;

  # App lancher
  programs.wofi = { enable = true; };

  # allow music controlls
  services.playerctld.enable = true;
  # allow copy history
  services.cliphist.enable = true;
  # allow browser
  programs.qutebrowser = { enable = true; };
}
