{ config, lib, ... }:
let
  cfg = config.homelab.authelia;
  secrets = config.sops.secrets;
in {
  options.homelab.authelia.oidc = {
    clients = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      default = [ ];
    };
  };

  config = lib.mkIf (cfg.enable && cfg.oidc.clients != [ ]) {
    sops.secrets = {
      "n100/authelia/oidc-hmac-secret" = { owner = "authelia-main"; };
      "n100/authelia/oidc-private-key" = { owner = "authelia-main"; };
    };
    services.authelia.instances.main = {
      secrets = {
        oidcHmacSecretFile = secrets."n100/authelia/oidc-hmac-secret".path;
        oidcIssuerPrivateKeyFile =
          secrets."n100/authelia/oidc-private-key".path;
      };
      settings = { identity_providers.oidc.clients = cfg.oidc.clients; };
    };
  };
}
