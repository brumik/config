{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.myHome.waybar;
  configPath = ".config/waybar";
in {
  options.myHome.waybar = {
    enable = mkEnableOption "Waybar autostart and configuration";
  };

  config = mkIf cfg.enable {
    home.file."${configPath}/styles.css".source = ./style.css;
    home.file."${configPath}/config.jsonc".source = ./config.jsonc;

    systemd.user.services.waybar = {
      Install = { WantedBy = [ "hyprland-service.target" ]; };

      Unit = { Description = "waybar"; };

      Service = {
        ExecStart = "${pkgs.waybar}/bin/waybar";
      };
    };
  };
}
