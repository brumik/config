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
        "The absolute path where the service will store the important information";
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
        # Use optimised flags: https://github.com/brucethemoose/Minecraft-Performance-Flags-Benchmarks
        jvmOpts = "-Xmx8G -Xms8G -XX:+UnlockExperimentalVMOptions -XX:+UnlockDiagnosticVMOptions -XX:+AlwaysPreTouch -XX:+DisableExplicitGC -XX:+UseNUMA -XX:NmethodSweepActivity=1 -XX:ReservedCodeCacheSize=400M -XX:NonNMethodCodeHeapSize=12M -XX:ProfiledCodeHeapSize=194M -XX:NonProfiledCodeHeapSize=194M -XX:-DontCompileHugeMethods -XX:MaxNodeLimit=240000 -XX:NodeLimitFudgeFactor=8000 -XX:+UseVectorCmov -XX:+PerfDisableSharedMem -XX:+UseFastUnorderedTimeStamps -XX:+UseCriticalJavaThreadPriority -XX:ThreadPriorityPolicy=1 -XX:AllocatePrefetchStyle=3  -XX:+UseG1GC -XX:MaxGCPauseMillis=37 -XX:+PerfDisableSharedMem -XX:G1HeapRegionSize=16M -XX:G1NewSizePercent=23 -XX:G1ReservePercent=20 -XX:SurvivorRatio=32 -XX:G1MixedGCCountTarget=3 -XX:G1HeapWastePercent=20 -XX:InitiatingHeapOccupancyPercent=10 -XX:G1RSetUpdatingPauseTimePercent=0 -XX:MaxTenuringThreshold=1 -XX:G1SATBBufferEnqueueingThresholdPercent=30 -XX:G1ConcMarkStepDurationMillis=5.0 -XX:G1ConcRSHotCardLimit=16 -XX:G1ConcRefinementServiceIntervalMillis=150 -XX:GCTimeRatio=99 -XX:+UseLargePages -XX:LargePageSizeInBytes=2m
";

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
          Antreew = "5ac3adee-40b3-42ea-b829-c559fcd420fc";
        };
      };
    };
  };
}
