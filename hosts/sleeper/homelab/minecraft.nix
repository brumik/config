{ config, lib, ... }:
let cfg = config.homelab.minecraft;
in {
  options.homelab.minecraft = {
    enable = lib.mkEnableOption "Immich";

    baseDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/minecraft";
      description =
        "The absolute path where the service will store the important informations";
    };
  };

  config = lib.mkIf cfg.enable {
    services.minecraft-server = {
      enable = true;
      openFirewall = true;
      declarative = true;
      eula = true;
      serverProperties = {
        server-port = 43000;
        max-players = 5;
        motd = "NixOS Minecraft server!";
        white-list = true;
        enable-rcon = false; # monitoring tool
        # "rcon.password" = "hunter2";
      };
      whitelist = {
        BrumBarnum = "332f4e53-0ceb-4655-89c8-fe6195d4afb9";
        Mordiath = "7958ffc4-c45c-4836-9c41-39454146bcf9";
        Emeariel = "9e800f97-0688-4173-99a0-1409c3e52a32";
      };
    };
  };
}
