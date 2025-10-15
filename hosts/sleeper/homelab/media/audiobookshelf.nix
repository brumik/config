{ config, lib, ... }:
let
  cfg = config.homelab.media.audiobookshelf;
  hcfg = config.homelab;
  dname = "${cfg.domain}.${config.homelab.domain}";
  baseDirDefaultVal = "/var/lib/audiobookshelf";
in {
  options.homelab.media.audiobookshelf = {
    enable = lib.mkEnableOption "audiobookshelf";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "audiobooks";
      description = "The subdomain where the service will be served";
    };

    baseDir = lib.mkOption {
      type = lib.types.path;
      default = baseDirDefaultVal;
      description = "The absolute path where the service will store the important informations";
    };
  };

  config = lib.mkIf (hcfg.enable && hcfg.media.enable && cfg.enable) {
    systemd.tmpfiles.rules = lib.mkIf (cfg.baseDir != baseDirDefaultVal) [
      "L ${baseDirDefaultVal} - - - - ${cfg.baseDir}"
    ];

    services.audiobookshelf = {
      enable = true;
      user = config.homelab.user;
      group = config.homelab.group;
      dataDir = "audiobookshelf";
      port = 18000; # default is 8000
    };

    homelab.traefik.routes = [{
      host = cfg.domain;
      port = 18000;
    }];

    homelab.authelia.exposedDomains = [ dname ];

    homelab.authelia.oidc.clients = [{
      client_id = "audiobookshelf";
      client_name = "Audiobookshelf";
      client_secret =
        "$pbkdf2-sha512$310000$1qc/K5ol5qE6BncjbiL8Og$VCNKDhSOYe.2/kshhegF9yg9rthQ3xUu8o6IyU5gmfABCiUwkI4MHwsrht27bQJcn3FtABaoCi4Jk3KMmMYjKw";
      public = false;
      consent_mode = "implicit";
      authorization_policy = "one_factor";
      require_pkce = true;
      pkce_challenge_method = "S256";
      redirect_uris = [
        "https://${dname}/auth/openid/callback"
        "https://${dname}/auth/openid/mobile-redirect"
      ];
      scopes = [ "openid" "email" "profile" "groups" ];
      userinfo_signed_response_alg = "none";
    }];

    homelab.backup.stateDirs = [ cfg.baseDir ];

    homelab.homepage.media = [{
      Audiobookshelf = {
        icon = "audiobookshelf.png";
        href = "https://${dname}";
        siteMonitor = "https://${dname}";
        description = "Audiobook service";
      };
    }];
  };
}
