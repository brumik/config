{ inputs, pkgs, config, lib, ... }:
let
  cfg = config.homelab.minecraft;
  minecraft = config.globals.users.minecraft;
in {
  imports = [ inputs.nix-minecraft.nixosModules.minecraft-servers ];

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
    nixpkgs.overlays = [ inputs.nix-minecraft.overlay ];

    users = {
      groups.${minecraft.gname} = { gid = minecraft.gid; };
      users.${minecraft.uname} = { uid = minecraft.uid; };
    };

    services.minecraft-servers = {
      enable = true;
      openFirewall = true;
      eula = true;

      dataDir = "/persist/minecraft";

      servers.vanilla1 = {
        enable = true;
        package = pkgs.vanillaServers.vanilla-1_21_11;
        jvmOpts = "-Xms2048M -Xmx6144M";

        serverProperties = {
          server-port = 43000;
          max-players = 10;
          motd = "Sleeper server (friends only UwU)";
          white-list = true;
        };

        whitelist = {
          BrumBarnum = "332f4e53-0ceb-4655-89c8-fe6195d4afb9";
          Mordiath = "7958ffc4-c45c-4836-9c41-39454146bcf9";
          Emeariel = "9e800f97-0688-4173-99a0-1409c3e52a32";
          innessa_art = "8f2594a7-a4fd-441c-96cb-957230f157d7";
          BNDR = "d73092cf-a57a-44da-a58f-739b047f7b1c";
        };
      };
    };
  };
}
