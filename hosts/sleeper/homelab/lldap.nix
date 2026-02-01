{ config, lib, ... }:
let
  cfg = config.homelab.lldap;
  dname = "${cfg.domain}.${config.homelab.domain}";
  lldap = config.globals.users.lldap;
in {
  options.homelab.lldap = {
    enable = lib.mkEnableOption "lldap";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "lldap";
      description = "The subdomain where the service will be served";
    };

    baseDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/lldap";
      description = "The absolute path where the service will store the important information";
    };
  };
  config = lib.mkIf cfg.enable {
    # create the user that run the service
    users.users."${lldap.uname}" = {
      isSystemUser = true;
      group = lldap.gname;
      uid = lldap.uid;
    };
    users.groups."${lldap.gname}" = { gid = lldap.gid; };

    sops.secrets."n100/lldap/key-seed" = { owner = lldap.uname; };
    sops.secrets."n100/lldap/smtp-pass" = { owner = lldap.uname; };
    sops.secrets."n100/lldap/admin-pass" = { owner = lldap.uname; };

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
        http_url = "https://${dname}";
        ldap_base_dn = "dc=berky,dc=me";
        # ldap_port = 3890 default
        database_url = "sqlite:///${cfg.baseDir}/users.db?mode=rwc";
        # Admin account:
        ldap_user_dn = "lldap_admin";
        ldap_user_email = "levente?admin@berky.me";
        ldap_user_pass_file = config.sops.secrets."n100/lldap/admin-pass".path;
        force_ldap_user_pass_reset = "always";
      };
    };

    homelab.traefik.routes = [{
      host = cfg.domain;
      port = 17170;
    }];

    # TODO close this when calibre-web is migrated away from docker
    networking.firewall.allowedTCPPorts = [ 3890 ];

    # Need to add private here since the service is already doing a symlink to it and we cannot follow it
    homelab.backup.stateDirs = [ cfg.baseDir "/var/lib/private/lldap" ];

    homelab.homepage.admin = [{
      LLDAP = {
        href = "https://${dname}";
        siteMonitor = "https://${dname}";
        description = "LDAP Server";
      };
    }];
  };
}
