{ config, lib, pkgs, ... }:
let cfg = config.homelab.lldap;
in {
  options.homelab.lldap = { enable = lib.mkEnableOption "lldap"; };
  config = lib.mkIf cfg.enable {
    # create the user that run the service
    users.users.lldap = {
      isSystemUser = true;
      group = "lldap";
    };
    users.groups.lldap = {};
    sops.secrets."n100/lldap-key-seed" = {
      owner = "lldap";
    };

    services.lldap = {
      enable = true;
      environment = {
        LLDAP_KEY_SEED_FILE = config.sops.secrets."n100/lldap-key-seed".path;
      };
      # TODO: This can break as unstable can change required variables
      # Once 25.05 update the system
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

    homelab.backup.stateDirs = [ "/var/lib/lldap" ];

    networking.firewall.allowedTCPPorts = [ 17170 ];
  };
}
