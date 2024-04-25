{ lib, pkgs, username, ... }:
  with lib.hm.gvariant;
{
  home.packages = [
    pkgs.gnomeExtensions.user-themes
    pkgs.gnomeExtensions.tiling-assistant
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

  home.file.".local/share/backgrounds/wallpaper.jpg".source = ./wallpaper.jpg;
  home.file.".local/share/backgrounds/wallpaper-nordic.jpg".source = ./wallpaper-nordic.jpg;

  dconf.settings = {
    "org/gnome/settings-daemon/plugins/power" = {
      sleep-inactive-ac-type = "nothing";
    };
    "org/gnome/desktop/background" = {
      color-shading-type = "solid";
      picture-options = "zoom";
      picture-uri = ".local/share/backgrounds/wallpaper.jpg";
      picture-uri-dark = ".local/share/backgrounds/wallpaper.jpg";
      primary-color = "#000000000000";
      secondary-color = "#000000000000";
    };

    "org/gnome/desktop/screensaver" = {
      color-shading-type = "solid";
      picture-options = "zoom";
      picture-uri = "file:///home/${username}/.local/share/backgrounds/wallpaper.jpg";
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
        "user-theme@gnome-shell-extensions.gcampax.github.com" 
        "tiling-assistant@leleat-on-github"
      ];
    };

    "org/gnome/shell/extensions/user-theme" = {
      name = "Nordic";
    };

    "org/gnome/shell/extensions/tiling-assistant" = {
      activate-layout0 = [];
      activate-layout1 = [];
      activate-layout2 = [];
      activate-layout3 = [];
      activate-layout4 = [];
      active-window-hint = 2;
      active-window-hint-border-size = 3;
      active-window-hint-color = "rgb(143,188,187)";
      active-window-hint-inner-border-size = 3;
      adapt-edge-tiling-to-favorite-layout = true;
      auto-tile = [];
      center-window = [];
      debugging-free-rects = [];
      debugging-show-tiled-rects = [];
      default-move-mode = 2;
      dynamic-keybinding-behavior = 4;
      enable-advanced-experimental-features = true;
      enable-raise-tile-group = false;
      enable-tile-animations = false;
      enable-tiling-popup = false;
      enable-untile-animations = false;
      estore-window = [];
      favorite-layouts = [ "4" ];
      import-layout-examples = false;
      last-version-installed = 44;
      maximize-with-gap = false;
      screen-bottom-gap = 4;
      screen-left-gap = 12;
      screen-right-gap = 12;
      screen-top-gap = 4;
      search-popup-layout = [];
      show-layout-panel-indicator = false;
      tile-bottom-half = [];
      tile-bottom-half-ignore-ta = [];
      tile-bottomleft-quarter = [];
      tile-bottomleft-quarter-ignore-ta = [];
      tile-bottomright-quarter = [];
      tile-bottomright-quarter-ignore-ta = [];
      tile-edit-mode = [];
      tile-left-half = [ "<Super>Left" ];
      tile-left-half-ignore-ta = [];
      tile-maximize = [];
      tile-maximize-horizontally = [];
      tile-maximize-vertically = [];
      tile-right-half = [ "<Super>Right" ];
      tile-right-half-ignore-ta = [];
      tile-top-half = [];
      tile-top-half-ignore-ta = [];
      tile-topleft-quarter = [];
      tile-topleft-quarter-ignore-ta = [];
      tile-topright-quarter = [];
      tile-topright-quarter-ignore-ta = [];
      toggle-always-on-top = [];
      toggle-tiling-popup = [];
      vertical-preview-area = 15;
      window-gap = 12;
    };
  };
}

