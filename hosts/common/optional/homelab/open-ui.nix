{ config, lib, ... }:
let
  cfg = config.homelab.open-webui;
  hcfg = config.homelab;
  dname = "${cfg.domain}.${hcfg.domain}";
in {
  options.homelab.open-webui = {
    enable = lib.mkEnableOption "open-webui";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "chat";
      description = "The subdomain where the service will be served";
    };

    baseDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/open-webui-oci";
      description =
        "The absolute path where the service will store the important informations";
    };
  };

  config = lib.mkIf cfg.enable {
    # Requires ollama running
    homelab.ollama = {
      enable = true;
      loadModels = [ "gemma3:12b" ];
    };

    sops.secrets = { "n100/open-webui/oidc-client-secret" = { }; };

    sops.templates."n100/open-webui/.env" = {
      content = ''
        OAUTH_CLIENT_SECRET=${
          config.sops.placeholder."n100/open-webui/oidc-client-secret"
        }
      '';
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.baseDir} 0755 share share -"
    ];

    virtualisation.oci-containers.containers.open-webui = {
      image = "ghcr.io/open-webui/open-webui:main";
      extraOptions = [ "--network=host" ];
      environment = {
        PORT = "11111";
        WEBUI_URL = "https://${dname}";

        ENABLE_OPENAI_API = "false";
        ENABLE_EVALUATION_ARENA_MODELS = "false";
        OLLAMA_API_BASE_URL =
          "http://127.0.0.1:${builtins.toString config.services.ollama.port}";
        DEFAULT_MODELS = "gemma3:12b";

        ENABLE_WEB_SEARCH = "true";
        WEB_SEARCH_ENGINE = "duckduckgo";

        ENABLE_OAUTH_SIGNUP = "true";
        ENABLE_LOGIN_FORM = "false";
        OAUTH_MERGE_ACCOUNTS_BY_EMAIL = "true";
        OAUTH_CLIENT_ID = "open-webui";
        OPENID_PROVIDER_URL =
          "https://${hcfg.authelia.domain}.${hcfg.domain}/.well-known/openid-configuration";
        OAUTH_PROVIDER_NAME = "Authelia";
        OAUTH_SCOPES = "openid email profile groups";
        ENABLE_OAUTH_ROLE_MANAGEMENT = "true";
        OAUTH_ALLOWED_ROLES = "openwebui,openwebui-admin";
        OAUTH_ADMIN_ROLES = "openwebui-admin";
        OAUTH_ROLES_CLAIM = "groups";
      };
      environmentFiles = [ config.sops.templates."n100/open-webui/.env".path ];
      volumes = [ "${cfg.baseDir}:/app/backend/data" ];
    };

    homelab.traefik.routes = [{
      host = cfg.domain;
      port = 11111;
    }];

    homelab.authelia.exposedDomains = [ dname ];

    homelab.authelia.oidc.clients = [{
      client_id = "open-webui";
      client_name = "Open WebUI";
      client_secret =
        "$pbkdf2-sha512$310000$8L3DJ9nnz//v0D8UTGxgCQ$.Qs65SRqjWjEh/SemClzwbZEpAjYBmYDVMTf3BpG7zuUpcqn3r.INYtI6DWhCoY40.qjjIOhqTpwiU/5soovbg";
      public = false;
      consent_mode = "implicit";
      authorization_policy = "one_factor";
      redirect_uris = [ "https://${dname}/oauth/oidc/callback" ];
      scopes = [ "openid" "email" "profile" "groups" ];
      userinfo_signed_response_alg = "none";
      token_endpoint_auth_method = "client_secret_basic";
    }];

    homelab.homepage.app = [{
      OpenWebUI = {
        icon = "open-webui.png";
        href = "https://${dname}";
        siteMonitor = "https://${dname}";
        description = "ChatGPT at home";
      };
    }];
  };
}
