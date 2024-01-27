{ lib, pkgs, ... }:
  with lib.hm.gvariant;
{
  home.packages = [
    pkgs.gnomeExtensions.user-themes
    pkgs.gnomeExtensions.paperwm
    pkgs.unstable.nordic
    pkgs.papirus-icon-theme
  ];

  gtk = {
    enable = true;

    theme = {
      name = "Nordic";
      package = pkgs.unstable.nordic;
    };

    iconTheme = {
      name = "Nordic-green";
      package = pkgs.unstable.nordic;
    };
    
    cursorTheme = {
      name = "Nordic-cursors";
      package = pkgs.unstable.nordic;
    };

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

  home.sessionVariables = {
    GTK_THEME = "Nordic";
    QT_STYLE_OVERRIDE = "Nordic";
  };

  home.file."/home/levente/.local/share/backgrounds/wallpaper.jpg".source = ./wallpaper.jpg;
  home.file."/home/levente/.local/share/backgrounds/wallpaper-nordic.jpg".source = ./wallpaper-nordic.jpg;

  dconf.settings = {
    "org/gnome/desktop/background" = {
      color-shading-type = "solid";
      picture-options = "zoom";
      picture-uri = "file:///home/levente/.local/share/backgrounds/wallpaper-nordic.jpg";
      picture-uri-dark = "file:///home/levente/.local/share/backgrounds/wallpaper-nordic.jpg";
      primary-color = "#000000000000";
      secondary-color = "#000000000000";
    };

    "org/gnome/desktop/screensaver" = {
      color-shading-type = "solid";
      picture-options = "zoom";
      picture-uri = "file:///home/levente/.local/share/backgrounds/wallpaper-nordic.jpg";
      primary-color = "#000000000000";
      secondary-color = "#000000000000";
    };

    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      enable-hot-corners = true;
    };

    "org.gnome.desktop.wm.preferences" = {
      theme = "Nordic";
    };

    "org/gnome/desktop/notifications" = {
      show-in-lock-screen = false;
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
      disable-user-extension = false;
      enabled-extensions = [
        "paperwm@paperwm.github.com"
        "user-theme@gnome-shell-extensions.gcampax.github.com" 
      ];
    };

    "org/gnome/shell/extensions/user-theme" = {
      name = "Nordic";
    };
  };
}

