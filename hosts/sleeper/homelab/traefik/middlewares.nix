{ config, ... }:
let authelia = config.homelab.authelia;
in {
  services.traefik.dynamicConfigOptions = {
    http.middlewares = {
      chain-authelia = {
        chain = {
          middlewares = [
            "middlewares-rate-limit"
            "middlewares-secure-headers"
            "middlewares-authelia"
          ];
        };
      };

      chain-authelia-local = {
        chain = {
          middlewares = [
            "middlewares-secure-headers"
            "middlewares-authelia"
          ];
        };
      };

      middlewares-authelia = {
        forwardAuth = {
          address = "http://${authelia.address}:${
              builtins.toString authelia.port
            }/api/authz/forward-auth";
          trustForwardHeader = true;
          authResponseHeaders =
            [ "Remote-User" "Remote-Groups" "Remote-Email" "Remote-Name" ];
        };
      };

      middlewares-rate-limit = {
        rateLimit = {
          average = 300;
          burst = 200; # mealie min 100, open-webui min 200
        };
      };

      middlewares-secure-headers = {
        headers = {
          # Allow cors headear from obsidian
          # Technically I could only apply it to some endpoint but 
          # I am bit lazy and it should be fine
          accessControlAllowOriginList = [ "app://obsidian.md" ]; 
          accessControlAllowHeaders = [ "Authorization" "Content-Type" ];
          accessControlAllowMethods = [ "GET" "POST" "OPTIONS" "PUT" "DELETE" ];
          accessControlAllowCredentials = true;

          accessControlMaxAge = 100;
          hostsProxyHeaders = [ "X-Forwarded-Host" ];
          stsSeconds = 63072000;
          stsIncludeSubdomains = true;
          stsPreload = true;
          # https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-Frame-Options
          customFrameOptionsValue = "SAMEORIGIN";
          contentTypeNosniff = true;
          browserXssFilter = true;
          referrerPolicy = "same-origin";
          # Leave the permission policy alone so we can use anything that we want
          # permissionsPolicy =
          #   "camera=(), microphone=(), geolocation=(), payment=(), usb=(), vr=()";
          customResponseHeaders = {
            # disable search engines from indexing home server
            X-Robots-Tag = "none,noarchive,nosnippet,notranslate,noimageindex,";
            # hide server info from visitors
            server = "";
          };
        };
      };
    };

    tls.options.default = {
      minVersion = "VersionTLS12";
      cipherSuites = [
        "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256"
        "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256"
        "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384"
        "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384"
        "TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305"
        "TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305"
        "TLS_AES_128_GCM_SHA256"
        "TLS_AES_256_GCM_SHA384"
        "TLS_CHACHA20_POLY1305_SHA256"
        "TLS_FALLBACK_SCSV" # Client is doing version fallback. See RFC 7507
      ];
      curvePreferences = [ "CurveP521" "CurveP384" ];
      sniStrict = true;
    };
  };
}
