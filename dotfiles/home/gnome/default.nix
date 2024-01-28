{ lib, pkgs, ... }:
  with lib.hm.gvariant;
{
  home.packages = [
    pkgs.gnomeExtensions.user-themes
    pkgs.gnomeExtensions.paperwm
    pkgs.gnomeExtensions.switcher
    pkgs.unstable.nordic
    pkgs.papirus-icon-theme
  ];

  gtk = {
    enable = true;

    # theme = {
    #   name = "Nordic";
    #   package = pkgs.unstable.nordic;
    # };

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

  # home.sessionVariables = {
  #   GTK_THEME = "Nordic";
  #   QT_STYLE_OVERRIDE = "Nordic";
  # };

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

    "org/gnome/desktop/wm/preferences" = {
      theme = "Nordic";
      num-workspaces = 3;
      workspace-names = [ "Main" "Code" "Other" ];
    };

    "org/gnome/desktop/notifications" = {
      show-in-lock-screen = false;
    };

    "org/gnome/desktop/session" = {
      idle-delay = mkUint32 0;
    };

    "org/gnome/mutter" = {
      attach-modal-dialogs = false;
      dynamic-workspaces = false;
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

    "org/gnome/shell/extensions/paperwm" = {
      default-focus-mode = 1;
      disable-scratch-in-overview = true;
      disable-topbar-styling = false;
      gesture-horizontal-fingers = 4;
      only-scratch-in-overview = false;
      open-window-position = 0;
      overview-ensure-viewport-animation = 1;
      restore-attach-modal-dialogs = "false";
      restore-edge-tiling = "false";
      show-focus-mode-icon = true;
      show-window-position-bar = false;
      use-default-background = false;
      winprops = [ ''
        {"wm_class":"firefox","preferredWidth":"49%","scratch_layer":false}
      '' ''
        {"wm_class":"Alacritty","preferredWidth":"49%"}
      '' ''
        {"wm_class":"Slack","preferredWidth":"24%"}
      '' ''
        {"wm_class":"Spotify","preferredWidth":"24%"}
      '' ];
    };
    "org/gnome/shell/extensions/paperwm/workspaces" = {
      list = [
        "workspace-main"
        "workspace-code"
        "workspace-other"
      ];
    };

    "org/gnome/shell/extensions/paperwm/workspaces/workspace-main" = {
      background = "/home/levente/.local/share/backgrounds/wallpaper-nordic.jpg";
      index = 0;
      name = "Main";
      show-top-bar = true;
    };


    "org/gnome/shell/extensions/paperwm/workspaces/workspace-code" = {
      background = "/home/levente/.local/share/backgrounds/wallpaper.jpg";
      color = "rgb(198,70,0)";
      index = 1;
      name = "Code";
    };

    "org/gnome/shell/extensions/paperwm/workspaces/workspace-other" = {
      background = "/home/levente/.local/share/backgrounds/wallpaper-nordic.jpg";
      color = "rgb(97,53,131)";
      index = 2;
      name = "Other";
    };

    "org/gnome/shell/extensions/user-theme" = {
      name = "Nordic";
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

