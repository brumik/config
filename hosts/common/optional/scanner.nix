{ config, lib, ... }:
let cfg = config.mySystems.scanner;
in {
  options.mySystems.scanner = {
    enable = lib.mkEnableOption "Brother scanner";

    users = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "The list of users added to the group of scanner";
    };
  };

  config = lib.mkIf cfg.enable {
    hardware.sane.enable = true;
    hardware.sane.brscan5.enable = true;

    users.groups.scanner.members = cfg.users;
    users.groups.lp.members = cfg.users;
  };
}
