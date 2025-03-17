{ config, lib, ... }:
let
  cfg = config.homelab.audiobookshelf;
  name = "audiobooks";
  dname = "${name}.${config.homelab.domain}";
in {
  options.homelab.audiobookshelf = {
    enable = lib.mkEnableOption "audiobookshelf";
  };

  config = lib.mkIf cfg.enable {
    services.audiobookshelf = {
      enable = true;
      user = config.homelab.user;
      group = config.homelab.group;
      dataDir = "audiobookshelf";
      port = 18000; # default is 8000
    };

    homelab.traefik.routes = [{
      host = name;
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

    homelab.backup.stateDirs = [ "/var/lib/audiobookshelf" ];
  };
}
