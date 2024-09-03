{ lib, pkgs, ... }:
  with lib.hm.gvariant;
{
  home.packages = [
    pkgs.gnomeExtensions.user-themes
    pkgs.gnomeExtensions.switcher
  ];

  gtk = {
    enable = true;

    gtk3.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
      '';
    };

    gtk4.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
      '';
    };
  };

  home.file.".face".source = ../../wallpapers/emily-portrait.png;

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      enable-hot-corners = true;
    };

    "org/gnome/desktop/notifications" = {
      show-in-lock-screen = true;
    };

    "org/gnome/desktop/session" = {
      idle-delay = mkUint32 300;
    };

    "org/gnome/settings-daemon/plugins/power" = {
      sleep-inactive-ac-type = "suspend";
      sleep-inactive-ac-timeout = 900;
    };

    "org/gnome/mutter" = {
      attach-modal-dialogs = false;
      dynamic-workspaces = true;
      edge-tiling = false;
      workspaces-only-on-primary = false;
    };

    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [
        "paperwm@paperwm.github.com"
        "user-theme@gnome-shell-extensions.gcampax.github.com" 
        "switcher@landau.fi"
      ];
    };
   
    "org/gnome/shell/extensions/switcher" = {
      activate-after-ms = mkUint32 200;
      activate-by-key = mkUint32 2;
      activate-immediately = true;
      fade-enable = true;
      font-size = mkUint32 24;
      icon-size = mkUint32 24;
      matching = mkUint32 1;
      max-width-percentage = mkUint32 25;
      show-executables = true;
    };
  };
}

