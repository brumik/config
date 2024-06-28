{ lib, ... }:
  with lib.hm.gvariant;
{
  gtk = {
    enable = true;
  };

  dconf.settings = {
    "org/gnome/settings-daemon/plugins/power" = {
      sleep-inactive-ac-type = "nothing";
    };

    "org/gnome/desktop/interface" = {
      enable-hot-corners = true;
    };

    "org/gnome/desktop/notifications" = {
      show-in-lock-screen = true;
    };

    "org/gnome/desktop/session" = {
      idle-delay = mkUint32 0;
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

