{ config, lib, ... }:
let
  cfg = config.homelab.authelia;
  secrets = config.sops.secrets;
  hcfg = config.homelab;
  storagePath = "${cfg.baseDir}/db.sqlite3";
  dname = "${cfg.domain}.${hcfg.domain}";
  instance = "main";
  redisPort = 6380;
  localSubnets = [ hcfg.subnet ]
    ++ (lib.optionals hcfg.tailscale.enable hcfg.tailscale.trustedIPs);
in {
  imports = [ ./oidc.nix ];

  options.homelab.authelia = {
    enable = lib.mkEnableOption "authelia";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "authelia";
      description = "The subdomain where the service will be served";
    };

    baseDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/authelia-main";
      description =
        "The absolute path where authelia will store the important information";
    };

    bypassDomains = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = ''
        The list of domains that have strong auth and will bypass authelia.
        It is recommended to put here domains that also will be acessesd from
        mobile applications (non browser).
      '';
    };

    localBypassDomains = lib.mkOption {
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
    # Define user ids
    users.users."${config.services.authelia.instances."${instance}".user}".uid =
      config.globals.users.authelia.uid;
    users.groups."${config.services.authelia.instances."${instance}".user}".gid =
      config.globals.users.authelia.gid;

    sops.secrets = {
      "n100/authelia/jwt-secret" = { owner = "authelia-main"; };
      "n100/authelia/session-secret" = { owner = "authelia-main"; };
      "n100/authelia/storage-encryption-key" = { owner = "authelia-main"; };
      "n100/authelia/lldap-pass" = { owner = "authelia-main"; };
      "n100/authelia/smtp-pass" = { owner = "authelia-main"; };
    };

    services.redis.servers.authelia = {
      enable = true;
      bind = "127.0.0.1"; # Only bind to localhost unless used remotely
      port = redisPort;
    };

    services.authelia.instances."${instance}" = {
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
        webauthn = {
          enable_passkey_login = true;
          attestation_conveyance_preference = "direct";
          filtering = { prohibit_backup_eligibility = true; };
          metadata = {
            enabled = true;
            validate_trust_anchor = true;
            validate_entry = true;
            validate_status = true;
            validate_entry_permit_zero_aaguid = false;
          };
        };
        log = {
          keep_stdout = true;
          level = "info"; # default is debug
        };
        server = {
          address = "tcp://${cfg.address}:${toString cfg.port}";
          endpoints.authz.forward-auth.implementation = "ForwardAuth";
        };
        totp = {
          issuer = hcfg.domain;
          period = 30;
          skew = 1;
        };

        session.redis = {
          host = "127.0.0.1";
          port = redisPort;
        };
        session.cookies = [{
          domain = hcfg.domain;
          authelia_url = "https://${cfg.domain}.${hcfg.domain}";
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
            # Always bypass the authelia
            domain = [ dname ];
            policy = "bypass";
          }] ++ (lib.optional (cfg.bypassDomains != [ ]) {
            # Bypass apps that have strong auth
            domain = cfg.bypassDomains;
            policy = "bypass";
          }) ++ (lib.optional (cfg.localBypassDomains != [ ]) {
            # Bypass apps that have strong auth
            domain = cfg.localBypassDomains;
            policy = "bypass";
            networks = localSubnets;
          }) ++ [{
            # On LAN we do one_factor (non guest network at least :)
            domain = [ "*.${hcfg.domain}" "${hcfg.domain}" ];
            networks = localSubnets;
            policy = "one_factor";
          }] ++ lib.optional (cfg.exposedDomains != [ ]) {
            # Allow apps from internet behind 2FA only
            domain = cfg.exposedDomains;
            policy = "two_factor";
          };
        };

        authentication_backend = {
          # Password reset through authelia works normally.
          password_reset.disable = false;
          refresh_interval = "1m";
          ldap = {
            implementation = "lldap";
            address = "ldap://127.0.0.1:3890";
            base_dn = "DC=berky,DC=me";
            # The username and password of the bind user.
            # "bind_user" should be the username you created for authentication
            # with the "lldap_strict_readonly" permission. It is not recommended
            # to use an actual admin account here.
            # If you are configuring Authelia to change user passwords, then the
            # account used here needs the "lldap_password_manager" permission instead.
            user = "UID=authelia,OU=people,DC=berky,DC=me";
            # Password set in environmentVariables
          };
        };
      };
    };

    homelab.traefik.routes = [{
      host = cfg.domain;
      port = cfg.port;
    }];

    homelab.authelia.bypassDomains = [ dname ];

    homelab.backup.stateDirs = [ storagePath ];

    homelab.homepage.admin = [{
      Authelia = {
        icon = "authelia.png";
        href = "https://${dname}";
        siteMonitor = "https://${dname}";
        description = "User authentication service (and reset password)";
      };
    }];
  };
}
