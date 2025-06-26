{ pkgs, ... }:
{
  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  environment.gnome.excludePackages = [
    pkgs.baobab      # disk usage analyzer
    pkgs.cheese      # photo booth
    pkgs.eog         # image viewer
    pkgs.epiphany    # web browser
    # pkgs.simple-scan # document scanner
    pkgs.totem       # video player
    pkgs.yelp        # help viewer
    pkgs.evince      # document viewer
    pkgs.geary       # email client
    pkgs.seahorse    # password manager

    # these should be self explanatory
    # pkgs.gnome-calculator
    pkgs.gnome-calendar
    pkgs.gnome-characters
    pkgs.gnome-clocks
    pkgs.gnome-contacts
    pkgs.gnome-font-viewer
    pkgs.gnome-logs
    pkgs.gnome-maps
    pkgs.gnome-music 
    pkgs.gnome-system-monitor
    pkgs.gnome-connections
  ];
  programs.dconf.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Hint electron apps to use wayland:
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
