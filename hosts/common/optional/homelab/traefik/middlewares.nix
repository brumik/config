{ ... }: {
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
      chain-no-auth = {
        chain = {
          middlewares =
            [ "middlewares-rate-limit" "middlewares-secure-headers" ];
        };
      };

      middlewares-authelia = {
        forwardAuth = {
          address = "http://authelia:9091/api/authz/forward-auth";
          trustForwardHeader = true;
          authResponseHeaders =
            [ "Remote-User" "Remote-Groups" "Remote-Email" "Remote-Name" ];
        };
      };

      middlewares-rate-limit = {
        rateLimit = {
          average = 200;
          burst = 100;
        };
      };

      middlewares-secure-headers = {
        headers = {
          accessControlAllowMethods = [ "GET" "OPTIONS" "PUT" ];
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
          permissionsPolicy =
            "camera=(), microphone=(), geolocation=(), payment=(), usb=(), vr=()";
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
