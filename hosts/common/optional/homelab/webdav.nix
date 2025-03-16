{ config, lib, ... }:
let
  cfg = config.homelab.webdav;
  name = "webdav";
  dname = "${name}.${config.homelab.domain}";
in {
  options.homelab.webdav = { enable = lib.mkEnableOption "webdav"; };

  config = lib.mkIf cfg.enable {
    sops.secrets."n100/webdav-users" = {
      owner = config.homelab.user;
    };

    services.webdav = {
      enable = true;
      user = config.homelab.user;
      group = config.homelab.group;
      settings = {
        address = "127.0.0.1";
        # port = "6065"; # default
        behindProxy = true;
        # the users and passwords are defined in the env file.
        users = [{
          username = "{env}ANTEATER";
          password = "{env}ANTEATER_PASS";
          directory = "/mnt/homes/Katerina/Drive";
          permissions = "CRUD";
        }];
      };
      environmentFile = config.sops.secrets."n100/webdav-users".path;
    };

    services.traefik = config.homelab.traefik.createRouter {
      name = name;
      port = 6065;
    };

    homelab.authelia.exposedDomains = [ dname ];
  };
}
