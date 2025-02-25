{ config, lib, pkgs, ... }:
  let cfg = config.mySystems.docker;
in {
  options.mySystems.docker = {
    enable = lib.mkEnableOption "docker";

    users = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "The list of users added to the group of docker";
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.docker.enable = true;
    
    # needs to add user group when used
    users.groups.docker.members = cfg.users;
    environment.systemPackages = with pkgs; [
      docker-compose
      # distrobox
    ];
  };
}
