{ ... }:
{
  imports = [
    ./hyprland.nix
    ./hyprpaper.nix
    ./waybar
  ];

  myHome.hyprpaper.enable = true;
  myHome.waybar.enable = true;

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
