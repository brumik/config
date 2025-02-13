{ lib, pkgs, ... }:
{
  home.packages = [
    # pkgs.gnomeExtensions.tiling-assistant
    pkgs.gnomeExtensions.steal-my-focus-window
    pkgs.gnomeExtensions.hide-top-bar
  ];

  home.file.".config/tiling-assistant/layouts.json".source = ./tiling-assistant-layouts.json;
  home.file.".face".source = ../../wallpapers/sebastian-portrait.png;

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
      idle-delay = lib.hm.gvariant.mkUint32 900;
    };

    "org/gnome/settings-daemon/plugins/power" = {
      sleep-inactive-ac-type = "suspend";
      sleep-inactive-ac-timeout = 1200;
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
        # "tiling-assistant@leleat-on-github"
        "steal-my-focus-window@steal-my-focus-window"
        "hidetopbar@mathieu.bidon.ca"
      ];
    };

    # "org/gnome/shell/extensions/tiling-assistant" = {
    #   activate-layout0 = [];
    #   activate-layout1 = [];
    #   activate-layout2 = [];
    #   activate-layout3 = [];
    #   activate-layout4 = [];
    #   active-window-hint = 2;
    #   active-window-hint-border-size = 3;
    #   # Defined in styles
    #   # active-window-hint-color = "rgb(143,188,187)";
    #   active-window-hint-inner-border-size = 3;
    #   adapt-edge-tiling-to-favorite-layout = true;
    #   auto-tile = [];
    #   center-window = [];
    #   debugging-free-rects = [];
    #   debugging-show-tiled-rects = [];
    #   default-move-mode = 2;
    #   dynamic-keybinding-behavior = 4;
    #   enable-advanced-experimental-features = true;
    #   enable-raise-tile-group = false;
    #   enable-tile-animations = false;
    #   enable-tiling-popup = false;
    #   enable-untile-animations = false;
    #   estore-window = [];
    #   favorite-layouts = [ "1" ];
    #   import-layout-examples = false;
    #   last-version-installed = 44;
    #   maximize-with-gap = false;
    #   screen-bottom-gap = 4;
    #   screen-left-gap = 12;
    #   screen-right-gap = 12;
    #   screen-top-gap = 4;
    #   search-popup-layout = [];
    #   show-layout-panel-indicator = false;
    #   tile-bottom-half = [];
    #   tile-bottom-half-ignore-ta = [];
    #   tile-bottomleft-quarter = [];
    #   tile-bottomleft-quarter-ignore-ta = [];
    #   tile-bottomright-quarter = [];
    #   tile-bottomright-quarter-ignore-ta = [];
    #   tile-edit-mode = [];
    #   tile-left-half = [ "<Super>Left" ];
    #   tile-left-half-ignore-ta = [];
    #   tile-maximize = [];
    #   tile-maximize-horizontally = [];
    #   tile-maximize-vertically = [];
    #   tile-right-half = [ "<Super>Right" ];
    #   tile-right-half-ignore-ta = [];
    #   tile-top-half = [];
    #   tile-top-half-ignore-ta = [];
    #   tile-topleft-quarter = [];
    #   tile-topleft-quarter-ignore-ta = [];
    #   tile-topright-quarter = [];
    #   tile-topright-quarter-ignore-ta = [];
    #   toggle-always-on-top = [];
    #   toggle-tiling-popup = [];
    #   vertical-preview-area = 15;
    #   window-gap = 12;
    # };
  };
}
