{ config, pkgs, lib, ... }:
let
  cfg = config.homelab.ollama;
  hcfg = config.homelab;
  dname = "${cfg.domain}.${hcfg.domain}";

  pythonEnv = pkgs.python311.withPackages (ps: with ps; [
    fastapi
    uvicorn
    httpx
  ]);

  ollamaWrapperScript = pkgs.writeText "main.py" ''
    from fastapi import FastAPI, Request, HTTPException, Response
    from fastapi.middleware.cors import CORSMiddleware
    import httpx
    import os

    app = FastAPI()

    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    OLLAMA_URL = os.getenv("OLLAMA_URL", "http://localhost:11434")
    BEARER_TOKEN = os.getenv("TOKEN")
    HOST = os.getenv("HOST")
    PORT = int(os.getenv("PORT"))

    @app.api_route("/{full_path:path}", methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"])
    async def proxy(full_path: str, request: Request):
        if request.method != "OPTIONS":
          auth = request.headers.get("Authorization")
          if auth != f"Bearer {BEARER_TOKEN}":
              raise HTTPException(status_code=401, detail="Unauthorized")

        async with httpx.AsyncClient() as client:
            body = await request.body()
            resp = await client.request(
                method=request.method,
                url=f"{OLLAMA_URL}/{full_path}",
                headers={k: v for k, v in request.headers.items() if k.lower() != "host"},
                content=body,
                timeout=None,
            )

        return Response(
            content=resp.content,
            status_code=resp.status_code,
            headers=dict(resp.headers),
            media_type=resp.headers.get("content-type")
        )

    if __name__ == "__main__":
        import uvicorn
        uvicorn.run(app, host=HOST, port=PORT)
  '';
in {
  options.homelab.ollama = {
    enable = lib.mkEnableOption "Ollama";

    loadModels = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description =
        "The list of models that will be avaiable after system build";
    };

    domain = lib.mkOption {
      type = lib.types.str;
      default = "ollama";
      description = "The subdomain where the service will be served";
    };
  };

  config = lib.mkIf cfg.enable {

    sops.secrets = { "n100/ollama/bearer" = { }; };
    sops.templates."n100/ollama/.env" = {
      content = ''
        TOKEN=${
          config.sops.placeholder."n100/ollama/bearer"
        }
      '';
    };

    services.ollama = {
      enable = true;
      host = "127.0.0.1";
      port = 11434;
      environmentVariables = {
        OLLAMA_ORIGINS = "*";
        OLLAMA_FLASH_ATTENTION = "1";
        # Gemma 27b does not fit with bigger context to VRAM
        # Slowdown without context is 3x
        # 32k for gemma:27b is 24Gb and devstral:24b is 22Gb, deepseek:32b does not fit
        OLLAMA_CONTEXT_LENGTH = "32000";
        # Keep models longer in memory
        OLLAMA_KEEP_ALIVE = "24h";
        # Qvantizing context slows down processing a lot (4x).
        # OLLAMA_KV_CACHE_TYPE = "q8_0";
      };
      loadModels = cfg.loadModels;
    };

    systemd.services.ollama-wrapper = {
      description = "Ollama Bearer Token Proxy";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      environment = {
        OLLAMA_URL = "http://localhost:11434";
        HOST = "127.0.0.1";
        PORT = "11116";
      };

      serviceConfig = {
        ExecStart = ''
          ${pythonEnv.interpreter} ${ollamaWrapperScript}
        '';
        EnvironmentFile = config.sops.templates."n100/ollama/.env".path;
      };
    };

    # We have Bearer auth here
    homelab.authelia.bypassDomains = [ dname ];

    homelab.traefik.routes = [{
      host = cfg.domain;
      port = 11116;
    }];

    homelab.homepage.services = [{
      Ollama = {
        icon = "ollama.png";
        href = "https://${dname}";
        siteMonitor = "https://${dname}";
        escription = "LLM at home";
      };
    }];
  };
}
