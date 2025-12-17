{ pkgs, ... }:
{
  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Disable default apps
  services.gnome.core-apps.enable = true;
  services.gnome.core-developer-tools.enable = false;
  services.gnome.games.enable = false;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Hint electron apps to use wayland: (should not be needed?)
  # environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
