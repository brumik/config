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
    users.groups.lldap = { };
    sops.secrets."n100/lldap/key-seed" = { owner = "lldap"; };
    sops.secrets."n100/lldap/smtp-pass" = { owner = "lldap"; };

    services.lldap = {
      enable = true;
      environment = {
        LLDAP_KEY_SEED_FILE = config.sops.secrets."n100/lldap/key-seed".path;
        LLDAP_SMTP_OPTIONS__ENABLE_PASSWORD_RESET = "true";
        LLDAP_SMTP_OPTIONS__SERVER = "smtp.m1.websupport.sk";
        LLDAP_SMTP_OPTIONS__PORT = "465";
        LLDAP_SMTP_OPTIONS__SMTP_ENCRYPTION = "TLS";
        LLDAP_SMTP_OPTIONS__USER = "lldap-noreply@berky.me";
        LLDAP_SMTP_OPTIONS__PASSWORD_FILE =
          config.sops.secrets."n100/lldap/smtp-pass".path;
        LLDAP_SMTP_OPTIONS__FROM = "LLDAP <lldap-noreply@berky.me>";
        LLDAP_SMTP_OPTIONS__TO = "Levente Berky <levente@berky.me>";
      };
      settings = {
        # Web user interface
        http_host = "localhost"; 
        # http_port = 17170 default
        # Password reset links:
        http_url = "https://lldap.${config.homelab.domain}";
        ldap_base_dn = "dc=berky,dc=me";
        # ldap_port = 3890 default
      };
    };

    homelab.traefik.routes = [{
      host = "lldap";
      port = 17170;
    }];

    homelab.backup.stateDirs = [ "/var/lib/lldap" ];

    homelab.homepage.admin = [{
      LLDAP = {
        href = "https://lldap.${config.homelab.domain}";
        siteMonitor = "https://lldap.${config.homelab.domain}";
        description = "LDAP Server";
      };
    }];
  };
}
