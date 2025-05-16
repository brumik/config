{ config, lib, ... }:
with lib;
let
  cfg = config.myHome.waybar;
in {
  options.myHome.waybar = {
    enable = mkEnableOption "Waybar autostart and configuration";
  };

  config = mkIf cfg.enable {
    programs.waybar = {
      enable = true;
      settings = [{
        layer = "top";
        position = "top";
        height = 24;

        modules-left = [ "hyprland/workspaces" "hyprland/window" ];
        modules-center = [ "clock" ];
        modules-right = [ "mpris" "group/aio" "privacy" "group/hardware" ];

        "hyprland/workspaces" = { format = "{id}"; };

        "hyprland/window" = {
          format = "{class}";
          max-length = 120;
          icon = false;
        };

        clock = {
          format = "{:%H:%M | %d %b}";
          tooltip = false;
        };

        mpris = {
          format = "{player_icon} {dynamic}";
          format-paused = "{status_icon} {dynamic}";
          max-length = 30;
        };

        privacy = {
          icon-spacing = 4;
          icon-size = 14;
          modules = [
            {
              type = "screenshare";
              tooltip = true;
            }
            {
              type = "audio-in";
              tooltip = true;
            }
          ];
        };

        "group/hardware" = {
          orientation = "horizontal";
          modules = [ "disk" "memory" "cpu" ];
        };

        disk = {
          format = "  {percentage_used}% |";
          path = "/";
          unit = "GB";
        };

        cpu = {
          format = "{icon}  {load}%";
          format-icons = [ "" ];
        };

        memory = {
          format = "{icon}  {percentage}% |";
          format-icons = [ "" ];
        };

        "group/aio" = {
          orientation = "horizontal";
          modules = [ "pulseaudio" ];
        };

        pulseaudio = {
          format = "{icon}  {volume}%";
          format-muted = "  --%";
          format-icons = {
            default = [ "" "" ];
            # Optional: You can define device-specific icons here
            # "alsa_output.usb-0b0e_Jabra_Link_370_305075769572-00.iec958-stereo" = "";
          };
        };
      }];

      style = ./style.css;
      systemd.enable = true;
    };
  };
}
