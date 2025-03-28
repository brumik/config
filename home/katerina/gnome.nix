{ lib, ... }:
{
  gtk = {
    enable = true;
  };

  home.file.".face".source = ../../assets/profile-pictures/emily-portrait.png;

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      enable-hot-corners = true;
    };

    "org/gnome/desktop/notifications" = {
      show-in-lock-screen = true;
    };

    "org/gnome/desktop/session" = {
      idle-delay = lib.hm.gvariant.mkUint32 0;
    };

    "org/gnome/settings-daemon/plugins/power" = {
      sleep-inactive-ac-type = "suspend";
      sleep-inactive-ac-timeout = 3600;
    };

    "org/gnome/mutter" = {
      attach-modal-dialogs = false;
      dynamic-workspaces = true;
      edge-tiling = false;
      workspaces-only-on-primary = false;
    };

    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [];
    };
  };
}

