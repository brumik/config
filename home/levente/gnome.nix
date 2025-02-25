{ pkgs, ... }:
{
  home.packages = [
    pkgs.gnomeExtensions.steal-my-focus-window
    pkgs.gnomeExtensions.hide-top-bar
  ];
  home.file.".face".source = ../../assets/profile-pictures/sebastian-portrait.png;

  gtk = {
    enable = true;
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      enable-hot-corners = true;
    };

    "org/gnome/desktop/wm/preferences" = {
      num-workspaces = 3;
      workspace-names = [ "Main" "Code" "Other" ];
    };

    "org/gnome/desktop/notifications" = {
      show-in-lock-screen = false;
    };

    "org/gnome/desktop/session" = {
      idle-delay = 0;
    };

    "org/gnome/settings-daemon/plugins/power" = {
      # After suspend either gnome or the OS got broken
      sleep-inactive-ac-type = "nothing";
    };

    "org/gnome/mutter" = {
      attach-modal-dialogs = false;
      dynamic-workspaces = false;
      edge-tiling = true;
      workspaces-only-on-primary = false;
    };

    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [
        "steal-my-focus-window@steal-my-focus-window"
        "hidetopbar@mathieu.bidon.ca"
      ];
    };
  };
}
