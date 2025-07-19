{ pkgs, lib, ... }: {
  home.packages = [ pkgs.gnomeExtensions.steal-my-focus-window ];

  home.file.".face".source = ../../assets/profile-pictures/emily-portrait.png;

  gtk = { enable = true; };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      enable-hot-corners = true;
    };

    "org/gnome/desktop/notifications" = { show-in-lock-screen = true; };

    "org/gnome/desktop/session" = {
      idle-delay = lib.hm.gvariant.mkUint32 600;
    };

    "org/gnome/settings-daemon/plugins/power" = {
      sleep-inactive-ac-type = "suspend";
      sleep-inactive-ac-timeout = 1200;
    };

    "org/gnome/mutter" = {
      attach-modal-dialogs = false;
      dynamic-workspaces = true;
      edge-tiling = true;
      workspaces-only-on-primary = false;
      experimental-features = [ "scale-monitor-framebuffer" ];
    };

    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [ ];
    };
  };
}
