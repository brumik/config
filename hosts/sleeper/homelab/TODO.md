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

### [SECURITY] Overly permissive CORS in Ollama
**Location:** `ollama.nix:24`
**Issue:** `allow_origins=["*"]` allows requests from any origin
**Impact:** Potential security vulnerability
**Fix:** Restrict to known origins or implement proper authentication

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

### [ORGANIZATION] Container-based services scattered
**Issue:** Services using oci-containers are mixed with native services:
- `wishlist.nix` (renamed from whislist.nix)
- `transmission.nix`
- `prowlarr.nix` (includes flaresolverr container)
- Others scattered
**Impact:** Harder to find container-based services
**Fix:** Create `homelab/containers/` subdirectory and group:
```
homelab/containers/
  wishlist.nix
  transmission/
    default.nix
    gluetun.nix
  prowlarr/
    default.nix
    flaresolverr.nix
```

### [MISSING] No documentation
**Issue:** No README explaining architecture, patterns, or how to add new services
**Impact:** Hard for future maintainers to understand structure
**Fix:** Create `homelab/README.md` with:
- Architecture overview
- Common patterns and utilities
- How to add a new service
- File structure explanation

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
2. [SECURITY] Fix CORS configuration in ollama
3. ~~[FILE] Rename whislist.nix → wishlist.nix~~ ✅ DONE
4. [DUPLICATE] Extract database dump pattern to shared module
5. ~~[TYPO] Fix ollama.nix description typo~~ ✅ DONE

### Medium Priority
6. [INCONSISTENT] Standardize tmpfiles quoting
7. [INCONSISTENT] Use service-config ports everywhere
8. [CLEANUP] Remove commented code or organize better
9. ~~[INCONSISTENT] Fix "informations" → "information"~~ ✅ DONE
10. [REFACTOR] Create shared utility module

### Low Priority (Nice to have)
11. [ORGANIZATION] Restructure into logical subdirectories
12. [MISSING] Create README documentation
13. [INCONSISTENT] Remove unnecessary intermediate variables

---

## Notes

- Always reference `config.globals.users` for UIDs/GIDs
- Follow existing patterns from AGENTS.md
- Test changes with `nix build` before applying
- Use `nix flake check` to validate
- Consider backward compatibility when refactoring
