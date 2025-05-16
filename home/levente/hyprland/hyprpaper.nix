{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.myHome.hyprpaper;
  configPath = ".config/hypr/hyprpaper.conf";
in {
  options.myHome.hyprpaper = {
    enable = mkEnableOption "Hyprpaper autostart and configuration";

    wallpaperFile = mkOption {
      type = types.path;
      description = "Path to the wallpaper image to be used by hyprpaper.";
    };
  };

  config = mkIf cfg.enable {
    home.file."${configPath}".text = ''
      preload = ${builtins.toString cfg.wallpaperFile}
      wallpaper = ,${builtins.toString cfg.wallpaperFile}
    '';

    systemd.user.services.hyprpaper = {
      Install = { WantedBy = [ "default.target" ]; };

      Unit = { Description = "hyprpaper"; };

      Service = {
        ExecStart = "${pkgs.hyprpaper}/bin/hyprpaper --config ${configPath}";
      };
    };
  };
}
