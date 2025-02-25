{ pkgs, ... }:
{
  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  environment.gnome.excludePackages = [
    pkgs.gnome.baobab      # disk usage analyzer
    pkgs.gnome.cheese      # photo booth
    pkgs.gnome.eog         # image viewer
    pkgs.gnome.epiphany    # web browser
    # pkgs.gnome.simple-scan # document scanner
    pkgs.gnome.totem       # video player
    pkgs.gnome.yelp        # help viewer
    pkgs.gnome.evince      # document viewer
    pkgs.gnome.geary       # email client
    pkgs.gnome.seahorse    # password manager

    # these should be self explanatory
    # pkgs.gnome.gnome-calculator
    pkgs.gnome.gnome-calendar
    pkgs.gnome.gnome-characters
    pkgs.gnome.gnome-clocks
    pkgs.gnome.gnome-contacts
    pkgs.gnome.gnome-font-viewer
    pkgs.gnome.gnome-logs
    pkgs.gnome.gnome-maps
    pkgs.gnome.gnome-music 
    pkgs.gnome.gnome-system-monitor
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
