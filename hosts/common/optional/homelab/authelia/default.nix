{ config, lib, ... }:
let
  cfg = config.homelab.authelia;
  secrets = config.sops.secrets;
  hcfg = config.homelab;
  storagePath = "/var/lib/authelia-main/db.sqlite3";
in {
  imports = [ ./oidc.nix ];

  options.homelab.authelia = {
    enable = lib.mkEnableOption "authelia";

    bypassDomains = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = ''
        The list of domains that have strong auth and will bypass authelia.
        It is recommended to put here domains that also will be acessesd from
        mobile applications (non browser).
      '';
    };

    exposedDomains = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = ''
        The list of domains that will be exposed to the internet, not only LAN, but
        are dependent on authelia. This includes also apps that use OIDC SSO Login.

        If outside of the network these domains will require you to have 2FA set up
        and will make you use 2FA for any login. This is obviously not going to work
        with Applications which can only use username/password instead of redirect.
      '';
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 9091;
    };

    address = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
    };
  };

  config = lib.mkIf cfg.enable {
    sops.secrets = {
      "n100/authelia/jwt-secret" = { owner = "authelia-main"; };
      "n100/authelia/session-secret" = { owner = "authelia-main"; };
      "n100/authelia/storage-encryption-key" = { owner = "authelia-main"; };
      "n100/authelia/lldap-pass" = { owner = "authelia-main"; };
      "n100/authelia/smtp-pass" = { owner = "authelia-main"; };
    };

    services.authelia.instances.main = {
      enable = true;
      secrets = {
        jwtSecretFile = secrets."n100/authelia/jwt-secret".path;
        sessionSecretFile = secrets."n100/authelia/session-secret".path;
        storageEncryptionKeyFile =
          secrets."n100/authelia/storage-encryption-key".path;
      };
      environmentVariables = {
        AUTHELIA_AUTHENTICATION_BACKEND_LDAP_PASSWORD_FILE =
          secrets."n100/authelia/lldap-pass".path;
        AUTHELIA_NOTIFIER_SMTP_PASSWORD_FILE =
          secrets."n100/authelia/smtp-pass".path;
      };
      settings = {
        log = {
          keep_stdout = true;
          level = "error"; # default is debug
        };
        server.address = "tcp://${cfg.address}:${builtins.toString cfg.port}";
        totp = {
          issuer = hcfg.domain;
          period = 30;
          skew = 1;
        };
        session.cookies = [{
          domain = hcfg.domain;
          authelia_url = "https://authelia.${hcfg.domain}";
          default_redirection_url = "https://${hcfg.domain}";
        }];
        notifier.smtp = {
          username = "authelia-noreply@berky.me";
          # Password set from env variables
          sender = "Authelia <authelia-noreply@berky.me>";
          address = "submissions://smtp.m1.websupport.sk:465";
        };
        storage.local.path = storagePath;

        access_control = {
          default_policy = "deny";
          # Reads from top to bottom and stops at the first matche when applying
          rules = [{
            # Bypass authelia on LAN (non guest network at least :)
            domain = [ "*.${hcfg.domain}" "${hcfg.domain}" ];
            networks = [ "192.168.0.0/16" ];
            policy = "bypass";
          }] ++ lib.optional (cfg.exposedDomains != [ ]) {
            # Allow apps from internet behind 2FA only
            domain = cfg.exposedDomains;
            policy = "two_factor";
          } ++ (lib.optional (cfg.bypassDomains != [ ]) {
            # Bypass apps that have strong auth
            domain = cfg.bypassDomains;
            policy = "bypass";
          });
        };

        authentication_backend = {
          # Password reset through authelia works normally.
          password_reset.disable = false;
          # How often authelia should check if there is an user update in LDAP
          refresh_interval = "1m";
          ldap = {
            implementation = "custom";
            # Pattern is ldap://HOSTNAME-OR-IP:PORT
            # Normal ldap port is 389, standard in LLDAP is 3890
            address = "ldap://127.0.0.1:3890";
            # The dial timeout for LDAP.
            timeout = "5s";
            # Use StartTLS with the LDAP connection, TLS not supported right now
            start_tls = "false";
            # Set base dn, like dc=google,dc.com
            base_dn = "dc=berky,dc=me";
            # You need to set this to ou=people, because all users are stored in this ou!
            additional_users_dn = "ou=people";
            # To allow sign in both with username and email, one can use a filter like
            # (&(|({username_attribute}={input})({mail_attribute}={input}))(objectClass=person))
            users_filter =
              "(&({username_attribute}={input})(objectClass=person))";
            # Set this to ou=groups, because all groups are stored in this ou
            additional_groups_dn = "ou=groups";
            # The groups are not displayed in the UI, but this filter works.
            groups_filter = "(member={dn})";
            # The attribute holding the name of the group.
            attributes = {
              display_name = "displayName";
              username = "uid";
              group_name = "cn";
              mail = "mail";
              # distinguished_name: distinguishedName
              # member_of: memberOf
            };

            # The username and password of the bind user.
            # "bind_user" should be the username you created for authentication
            # with the "lldap_strict_readonly" permission. It is not recommended
            # to use an actual admin account here.
            # If you are configuring Authelia to change user passwords, then the
            # account used here needs the "lldap_password_manager" permission instead.
            user = "uid=authelia,ou=people,dc=berky,dc=me";
            # Password set in environmentVariables
          };
        };
      };
    };

    homelab.traefik.routes = [{
      host = "authelia";
      port = cfg.port;
    }];

    homelab.authelia.bypassDomains = [ "authelia.${config.homelab.domain}" ];

    homelab.backup.stateDirs = [ storagePath ];
  };
}
