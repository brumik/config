{ config, lib, pkgs, ... }:
let cfg = config.homelab.lldap;
in {
  options.homelab.lldap = { enable = lib.mkEnableOption "lldap"; };
  config = lib.mkIf cfg.enable {
    services.lldap = {
      enable = true;
      environment = {
        LLDAP_KEY_SEED_FILE = "./key_seed";
      };
      package = pkgs.unstable.lldap;
      settings = {
        # Web user interface
        http_host = "0.0.0.0"; # TODO change to localhost
        # http_port = 17170 default
        # Password reset links:
        http_url = "https://lldap.${config.homelab.domain}";
        ldap_base_dn = "dc=berky,dc=me";
        # ldap_port = 3890 default
      };
    };

    networking.firewall.allowedTCPPorts = [ 17170 ];
  };
}
