{ config, pkgs, lib, ... }:
let
  cfg = config.homelab.karakeep;
  hcfg = config.homelab;
  dname = "${cfg.domain}.${hcfg.domain}";
  baseDirDefaultVal = "/var/lib/karakeep";
  ollama = config.services.ollama;
in {
  options.homelab.karakeep = {
    enable = lib.mkEnableOption "Karakeep";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "karakeep";
      description = "The subdomain where the service will be served";
    };

    baseDir = lib.mkOption {
      type = lib.types.path;
      default = baseDirDefaultVal;
      description =
        "The absolute path where the service will store the important informations";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.karakeep = { uid = 1100; };
    users.groups.karakeep = { gid = 1101; };

    systemd.tmpfiles.rules = lib.mkIf (cfg.baseDir != baseDirDefaultVal) [
      "d ${cfg.baseDir} 0755 root root -"
      "L ${baseDirDefaultVal} - - - - ${cfg.baseDir}"
      "d /var/cache/karakeep-ocr 0750 karakeep karakeep -"
    ];

    sops.secrets = { "n100/karakeep/oidc-client-secret" = { }; };

    sops.templates."n100/karakeep/config-secrets" = {
      content = ''
        OAUTH_CLIENT_SECRET=${
          config.sops.placeholder."n100/karakeep/oidc-client-secret"
        }
      '';
      owner = "karakeep";
    };

    assertions = [{
      assertion = hcfg.ollama.enable;
      message = "Karakeep depends on ollama";
    }];

    homelab.ollama.loadModels = [ "gemma3:27b" ];

    services.karakeep = {
      enable = true;
      environmentFile =
        config.sops.templates."n100/karakeep/config-secrets".path;
      extraEnvironment = {
        PORT = "10005";
        NEXTAUTH_URL = "https://${dname}";
        DISABLE_NEW_RELEASE_CHECK = "true";
        OAUTH_WELLKNOWN_URL =
          "https://${config.homelab.authelia.domain}.${config.homelab.domain}/.well-known/openid-configuration";
        OAUTH_CLIENT_ID = "karakeep";
        OAUTH_PROVIDER_NAME = "Authelia";
        OAUTH_SCOPE = "openid email profile";
        DISABLE_SIGNUPS = "false"; # we want to allow signup with authelia
        DISABLE_PASSWORD_AUTH = "true";

        # AI
        OLLAMA_BASE_URL = "http://${ollama.host}:${toString ollama.port}";
        INFERENCE_TEXT_MODEL = "gemma3:27b";
        INFERENCE_IMAGE_MODEL = "gemma3:27b";
        EMBEDDING_TEXT_MODEL = "mxbai-embed-large";
        INFERENCE_CONTEXT_LENGTH =
          ollama.environmentVariables.OLLAMA_CONTEXT_LENGTH;
        INFERENCE_ENABLE_AUTO_TAGGING = "true";
        INFERENCE_ENABLE_AUTO_SUMMARIZATION = "true";
        INFERENCE_JOB_TIMEOUT_SEC = "120";

        # set cache:
        OCR_CACHE_DIR = "/var/cache/karakeep-ocr";
      };
      meilisearch.enable = true;
      browser.enable = true;
    };

    services.meilisearch.package = pkgs.meilisearch;

    homelab.traefik.routes = [{
      host = cfg.domain;
      port = 10005;
    }];

    # The nextauth will try to reach out to his OWN url and cannot have authelia return a non
    # allowed error, otherwise cannot create auth methods and login won't work
    homelab.authelia.bypassDomains = [ dname ];

    homelab.backup.stateDirs = [ cfg.baseDir ];

    homelab.homepage.app = [{
      Karakeep = {
        icon = "karakeep.png";
        href = "https://${dname}";
        siteMonitor = "https://${dname}";
        description = "Archive and make websites searchable";
      };
    }];

    homelab.authelia.oidc.clients = [{
      client_id = "karakeep";
      # This is a hotfix for the karakeep needs the email in the id token. 
      # The policy it defined in authelia/oicd.nix
      # https://www.authelia.com/integration/openid-connect/clients/karakeep/
      # https://github.com/karakeep-app/karakeep/pull/1268 - possible resolution so we don't need this workaround
      claims_policy = "karakeep";
      client_name = "Karakeep";
      client_secret =
        "$pbkdf2-sha512$310000$5vxFjg3.l9aWrQ1EGTY8tw$yTEKiXWA68rx6gGaWq/Z2/9haxziCpAv2K5CGPpjJ1pv/7klr1FlA82.xoL1gpvHS21utxIHD4q1yLOn5a/waA";
      public = false;
      consent_mode = "implicit";
      authorization_policy = "one_factor";
      require_pkce = false;
      pkce_challenge_method = "";
      redirect_uris = [ "https://${dname}/api/auth/callback/custom" ];
      scopes = [ "openid" "email" "profile" ];
      response_types = [ "code" ];
      grant_types = [ "authorization_code" ];
      userinfo_signed_response_alg = "none";
      token_endpoint_auth_method = "client_secret_basic";
    }];
  };
}
