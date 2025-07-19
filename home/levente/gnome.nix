{ pkgs, lib, ... }: {
  home.packages = [ pkgs.gnomeExtensions.steal-my-focus-window ];

  home.file.".face".source =
    ../../assets/profile-pictures/sebastian-portrait.png;

  gtk = { enable = true; };

  dconf.settings = {
    "org/gnome/desktop/interface" = { enable-hot-corners = true; };

    "org/gnome/desktop/wm/preferences" = {
      num-workspaces = 3;
      workspace-names = [ "Main" "Code" "Other" ];
    };

    "org/gnome/desktop/notifications" = { show-in-lock-screen = false; };

    "org/gnome/desktop/session" = {
      idle-delay = lib.hm.gvariant.mkUint32 600;
    };

    "org/gnome/settings-daemon/plugins/power" = {
      # After suspend either gnome or the OS got broken
      sleep-inactive-ac-type = "suspend";
      sleep-inactive-ac-timeout = 1200;
    };

    "org/gnome/mutter" = {
      attach-modal-dialogs = false;
      dynamic-workspaces = false;
      edge-tiling = true;
      workspaces-only-on-primary = false;
      experimental-features = [ "scale-monitor-framebuffer" ];
    };

    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [ "steal-my-focus-window@steal-my-focus-window" ];
    };
  };
}
