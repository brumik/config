{ config, lib, ... }:
let
  cfg = config.homelab.open-webui;
  hcfg = config.homelab;
  ocfg = config.homelab.ollama;
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
    assertions = [{
      assertion = hcfg.ollama.enable;
      message = "Mealie depends on ollama";
    }];

    sops.secrets = { "n100/open-webui/oidc-client-secret" = { }; };

    sops.templates."n100/open-webui/.env" = {
      content = ''
        OAUTH_CLIENT_SECRET=${
          config.sops.placeholder."n100/open-webui/oidc-client-secret"
        }
      '';
    };

    systemd.tmpfiles.rules = [ "d ${cfg.baseDir} 0755 share share -" ];

    # Enable text extraction engine:
    services.tika.enable = true;

    virtualisation.oci-containers.containers.open-webui = {
      image = "ghcr.io/open-webui/open-webui:main";
      extraOptions = [ "--network=host" ];
      pull = "always";
      environment = {
        PORT = "11111";
        WEBUI_URL = "https://${dname}";
        # This is generated in docker on first startup
        # WEBUI_SECRET_KEY

        ENABLE_OPENAI_API = "False";
        ENABLE_EVALUATION_ARENA_MODELS = "False";
        OLLAMA_BASE_URL =
          "http://127.0.0.1:${builtins.toString config.services.ollama.port}";
        DEFAULT_MODELS = ocfg.defaultInference;

        ENABLE_WEB_SEARCH = "true";
        WEB_SEARCH_ENGINE = "duckduckgo";

        USER_PERMISSIONS_WORKSPACE_MODELS_ACCESS = "True";
        USER_PERMISSIONS_WORKSPACE_KNOWLEDGE_ACCESS = "True";
        USER_PERMISSIONS_WORKSPACE_PROMPTS_ACCESS = "True";
        USER_PERMISSIONS_WORKSPACE_TOOLS_ACCESS = "True";

        RAG_OLLAMA_BASE_URL =
          "http://127.0.0.1:${builtins.toString config.services.ollama.port}";
        RAG_EMBEDDING_ENGINE = "ollama";
        RAG_EMBEDDING_MODEL = ocfg.defaultEmbed;
        CONTENT_EXTRACTION_ENGINE = "tika";
        TIKA_SERVER_URL = "http://127.0.0.1:9998";
        RAG_TOP_K = "10";

        WHISPER_MODEL="medium";

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
        ENABLE_OAUTH_PERSISTENT_CONFIG = "false";

        # To treat all env variables the same, which means on restart reaply them
        # removing any changes made in the UI
        ENABLE_PERSISTENT_CONFIG = "False";
      };
      environmentFiles = [ config.sops.templates."n100/open-webui/.env".path ];
      volumes = [ "${cfg.baseDir}:/app/backend/data" ];
    };

    homelab.backup.stateDirs = [ cfg.baseDir ];

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
