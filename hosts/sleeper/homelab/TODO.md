# Homelab Improvements TODO

This document tracks improvements and issues identified in the homelab configuration. Each item includes context, location, and suggested fixes.

## Critical Security Issues

### [SECURITY] Hardcoded secrets in Traefik
**Location:** `traefik/default.nix:46`
**Issue:** `WEBSUPPORT_API_KEY` is hardcoded in the template file instead of using sops-nix
**Impact:** API key exposed in Nix store and Git history
**Fix:**
```nix
sops.secrets."n100/traefik/websupport-api-key" = { };
sops.templates."n100/traefik/.env" = {
  content = ''
    WEBSUPPORT_SECRET=${config.sops.placeholder."n100/traefik/websupport-secret"}
    WEBSUPPORT_API_KEY=${config.sops.placeholder."n100/traefik/websupport-api-key"}
    LEGO_DISABLE_CNAME_SUPPORT=true
  '';
};
```

### [SECURITY] Hardcoded OIDC client secret in Immich
**Location:** `immich.nix:115-116`
**Issue:** OIDC client secret is hardcoded directly in config
**Impact:** Secret exposed in Nix store
**Fix:** Move to sops secrets and reference via placeholder

### [SECURITY] Hardcoded OIDC client secret in Nextcloud
**Location:** `nextcloud.nix:209-210`
**Issue:** OIDC client secret is hardcoded directly in config
**Impact:** Secret exposed in Nix store
**Fix:** Move to sops secrets and reference via placeholder

---

## File Naming & Typos

### [FILE] ~~Incorrect filename~~ ✅ FIXED
**Location:** `whislist.nix` → `wishlist.nix`
**Issue:** Filename has typo (should be "wishlist")
**Impact:** Inconsistent naming, confusion
**Fix:** Renamed to `wishlist.nix` and updated imports in `default.nix:36`

### [TYPO] ~~Typo in ollama.nix~~ ✅ FIXED
**Location:** `ollama.nix:171`
**Issue:** `escription` instead of `description`
**Impact:** Homepage dashboard may not display properly
**Fix:** Changed to `description = "LLM at home";`

---

## Code Duplication

### [DUPLICATE] Database dump pattern (Immich & Nextcloud)
**Location:**
- `immich.nix:65-91`
- `nextcloud.nix:155-185`
**Issue:** Comments explicitly acknowledge duplication: "Duplicated in Nextcloud"
**Impact:** Maintenance burden, inconsistent behavior
**Fix:** Create shared module `homelab/utils/postgres-dump.nix`:
```nix
{ config, pkgs, dbName, serviceName, preStopService ? null }:
let
  dumpService = "pgDump${builtins.replaceStrings ["-"] [""] serviceName}";
in {
  systemd.tmpfiles.rules = [ "d /var/lib/pgdump 0755 postgres postgres -" ];

  systemd.services.${dumpService} = {
    description = "PostgreSQL dump of the ${dbName} database";
    after = [ "postgresql.service" ];
    serviceConfig = {
      Type = "oneshot";
      User = "postgres";
      ExecStart = "${pkgs.postgresql}/bin/pg_dump -f /var/lib/pgdump/${dbName}_dump.sql ${dbName}";
    };
  };

  homelab.backup = {
    preBackupScripts = [ "systemctl start ${dumpService}" ];
    postBackupScripts = [ ];
  };
}
```

### [DUPLICATE] Common service patterns
**Issue:** Repeated patterns across services:
- Domain construction: `dname = "${cfg.domain}.${hcfg.domain}"`
- Traefik routes registration
- Homepage dashboard registration
- Backup stateDirs registration
**Impact:** Boilerplate, harder to maintain
**Fix:** Create helper functions in `homelab/utils/default.nix`

---

## Inconsistencies & Style Issues

### [INCONSISTENT] Unnecessary intermediate variables
**Locations:**
- `radarr.nix:5` - `baseDirDefaultVal`
- `prowlarr.nix:5` - `baseDirDefaultVal`
- `nextcloud.nix:6` - `baseDirDefaultVal`
**Issue:** Variables defined only to be used as default values
**Impact:** Unnecessary complexity
**Fix:** Use inline default values in options:
```nix
baseDir = lib.mkOption {
  type = lib.types.path;
  default = "/var/lib/radarr";
  description = "The absolute path where the service will store important information";
};
```

### [INCONSISTENT] ~~Grammatical errors~~ ✅ FIXED
**Locations:** Multiple files throughout homelab/
**Issue:** "informations" used instead of "information" (mass noun)
**Impact:** Unprofessional, inconsistent with English grammar
**Fix:** Replaced all occurrences (26) of "informations" with "information"

### [INCONSISTENT] tmpfiles syntax quoting
**Locations:**
- `transmission.nix:28-35` - No quotes around paths
- `radarr.nix:26-28` - Quotes around paths
**Issue:** Inconsistent quoting style
**Impact:** Harder to review, potential for errors
**Fix:** Choose one style (recommended: no quotes for simple paths)

### [INCONSISTENT] Port references
**Locations:**
- `homepage.nix:58` - Hardcoded port `8082`
- `immich.nix:56` - Uses `config.services.immich.port`
**Issue:** Some services hardcode ports, others reference config
**Impact:** Breaks if port is changed in service config
**Fix:** Always reference service configuration for ports

---

## Missing Features & Organization

### [CLEANUP] Commented code blocks
**Locations:**
- `prowlarr.nix:26-34` - Awaiting NixOS 25.11 native service
- `jellyfin.nix:34-39` - Jellyfin-rewind container (CORS issues)
- `traefik/default.nix:90` - Staging CA server config
- `transmission.nix:26-27` - Old tmpfiles rules
**Impact:** Clutter, confusion about what's active
**Fix:**
- Remove outdated code
- Create `TODO-nixos25.11.md` for future changes
- Use git history if needed

---

## Structural Improvements

### [REFACTOR] Create shared utility module
**Issue:** No centralized utilities for common patterns
**Impact:** Boilerplate repetition
**Fix:** Create `homelab/utils/default.nix` with helpers:
```nix
{ lib, config }:
rec {
  mkService = { name, domain, port, description, icon, ... }: {
    homelab.traefik.routes = [{ host = domain; inherit port; }];
    homelab.homepage.app = [{
      ${name} = {
        inherit icon description;
        href = "https://${domain}.${config.homelab.domain}";
        siteMonitor = "https://${domain}.${config.homelab.domain}";
      };
    }];
  };

  mkDomainName = domain: "${domain}.${config.homelab.domain}";
}
```

### [REFACTOR] Group services logically
**Current structure:** Flat list of 40+ files
**Proposed structure:**
```
homelab/
  auth/              # Authentication & identity
    authelia/
    lldap.nix
  containers/        # OCI container services
    wishlist.nix
    transmission/
  media/             # Media stack (existing)
  monitoring/        # Monitoring stack (existing)
  database/          # Database-related configs
    postgres-dump.nix
  utils/             # Shared utilities
    default.nix
  *.nix              # Individual services (native)
```

---

## Prioritization

### High Priority (Do first)
1. [SECURITY] Move all hardcoded secrets to sops
2. [DUPLICATE] Extract database dump pattern to shared module

### Medium Priority
3. [INCONSISTENT] Standardize tmpfiles quoting
4. [INCONSISTENT] Use service-config ports everywhere
5. [CLEANUP] Remove commented code or organize better
6. [INCONSISTENT] Remove unnecessary intermediate variables
7. [REFACTOR] Create shared utility module

### Low Priority (Nice to have)
8. [REFACTOR] Restructure into logical subdirectories

---

## Notes

- Always reference `config.globals.users` for UIDs/GIDs
- Follow existing patterns from AGENTS.md
- Test changes with `nix build` before applying
- Use `nix flake check` to validate
- Consider backward compatibility when refactoring

---

## Port Configuration Audit

### Port Audit Summary Table

| Service | Port (Current) | Format | Status | Note |
|---------|---------------|--------|--------|------|
| **Authelia** | 9091 | ✅ Config option + reference | OK | Option defined: `port = lib.mkOption { type = lib.types.port; default = 9091; }` |
| **LLLARP** | N/A | ✅ Not applicable | MISSING FILE | File `llarp/.nix` does not exist in repository |
| **Vaultwarden** | 11110 | ⚠️ No option | NEEDS FIX | No port option defined, both service and Traefik use hardcoded:11110 |
| **Home Assistant** | 8123 | ⚠️ No option | NEEDS FIX | No port option defined, both service and Traefik use hardcoded:8123 |
| **Radicale** | 5232 | ⚠️ No option | NEEDS FIX | No port option defined, both service and Traefik use hardcoded:5232 |
| **Lldap** | 17170 | ⚠️ No option | NEEDS FIX | No port option defined, both service and Traefik use hardcoded:17170 |
| **Jellyfin** | 8096 | ✅ No option | OK | Both service (8096) and Traefik reference same value |
| **Jellyseerr** | 5055 | ✅ No option | OK | Both service (5055) and Traefik reference same value |
| **Audiobookshelf** | 18000 | ✅ No option | OK | Both service (18000) and Traefik reference same value |
| **Calibre** | 11080/8080 | ✅ Container mapping | DOC | Container: `11080:8080`, Traefik uses external:11080 |
| **Lidarr** | 8686 | ✅ No option | OK | Both service (8686) and Traefik reference same value |
| **Radarr** | 7878 | ✅ No option | OK | Both service (7878) and Traefik reference same value |
| **Sonarr** | 8989 | ✅ No option | OK | Both service (8989) and Traefik reference same value |
| **Prowlarr** | 9696 | ✅ No option | OK | Both service (9696) and Traefik reference same value |
| **Bazarr** | 6767 | ✅ No option | OK | Both service (6767) and Traefik reference same value |
| **Transmission** | 9092/51413 | ✅ Container mapping | DOC | Custom container: `9092:9091` + `51413:51413`, Traefik uses external:9092 |
| **Soulseek** | 5030/6080 | ✅ Container mapping | DOC | Custom container: `5030:6080`, Traefik uses external:5030 |
| **Mealie** | 9000 | ✅ No option | OK | Both service (9000) and Traefik reference same value |
| **Recyclarr** | N/A | 🔴 CRITICAL | CRITICAL | No web UI but **hardcodes sonarr (8989) and radarr (7878) internally** |
| **Prometheus** | 9093 | ✅ Config option + reference | OK | Main: `port = 9093`; exporters use `toString config.services.prometheus.exporters.*.port` |
| **Grafana** | 3000 | ✅ Config option + reference | OK | Traefik uses `config.services.grafana.settings.server.http_port` |
| **Loki** | 3030 | ✅ Config option + reference | OK | Loki (3030) and Promtail (3031) use config references |
| **Immich** | 2283 | ✅ No option | OK | Service uses hardcoded:2283, Traefik references same value |
| **Nextcloud** | 11112 | ⚠️ No option | NEEDS FIX | No port option defined, Traefik uses hardcoded:11112 |
| **Ollama** | 11116 | ✅ Proxy service | INFO | Using systemd proxy service (11116) for Authelia bypass, not native port (11434) |
| **Open-WebUI** | 11111 | ⚠️ No option | NEEDS FIX | No port option defined, uses `--network=host` with hardcoded:11111 |
| **FreshRSS** | 10003 | ⚠️ No option | NEEDS FIX | No port option defined, Traefik uses hardcoded:10003 |
| **Kiwix** | 10004 | ⚠️ No option | NEEDS FIX | No port option defined, Traefik uses hardcoded:10004 |
| **Stirling-PDF** | 11120 | ⚠️ No option | NEEDS FIX | No port option defined, uses env var `SERVER_PORT=11120` |
| **AdGuard** | 10000 | ⚠️ No option | NEEDS FIX | No port option defined, Traefik uses hardcoded:10000 |
| **Cache Server** | 11117 | ⚠️ No option | NEEDS FIX | No port option defined, Traefik uses hardcoded:11117 |

### Format Examples

#### Proper Pattern (Authelia, Prometheus, Grafana, Loki):
```nix
# Define port in homelab namespace options
services.authelia = {

    port = 9096; # or any other nix option that lets to define the port
}
# Use in Traefik routes (toString is needed for port type)
homelab.traefik.routes = [{
  host = cfg.domain;
  port = config.services.authelia.port; # or the exact config that the service uses
}];

# Or in service config if port needs to be passed
address = "https://${...}:${toString cfg.port}";
```

#### Current Pattern (Mixed - Nextcloud etc):
```nix
# No port option defined
# Service config with hardcoded port
homelab.traefik.routes = [{
  host = "cloud.${config.homelab.domain}";
  port = 11112;  # ❌ Hardcoded literal
}];
```

### Issue Summary

### Notes
- Ollama uses a systemd proxy wrapper service on port 11116 for Authelia bypass, not the native HTTP API port (11434)
- Custom Docker port mappings (Calibre, Transmission, Soulseek) require explicit host mapping and documented port numbers in service config
- Monitoring stack (Prometheus, Grafana, Loki) already follows proper config reference pattern
- Services without options can be left as-is if they're not expected to change ports
