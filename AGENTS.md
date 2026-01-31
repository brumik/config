# AGENTS.md

This file contains guidelines for agentic coding assistants working in this NixOS configuration repository.

---

# Repository Overview

This repository contains:
- **/home/** - Home Manager configuration for user dotfiles and programs
- **/hosts/** - NixOS system configurations split by host:
  - **/hosts/sleeper/** - Server with homelab services (podman, traefik, monitoring, media, etc.)
  - **/hosts/common/** - Shared modules for all NixOS hosts
  - **/hosts/{brumstellar,anteater,sas,live}/** - Non-server hosts (desktop/laptop systems)

---

# Build, Lint, and Test Commands

## General Commands
- `nix flake update` - Update all flake inputs
- `nix flake check` - Validates flake structure

## NixOS System Builds
- `sudo nixos-rebuild switch --flake .` - Rebuild and switch to new configuration (auto-detects hostname)
- `sudo nixos-rebuild switch --flake .#hostname` - Rebuild specific host configuration
- `just rebuild` - Alias for rebuild command
- `nix build .#nixosConfigurations.nixos-live.config.system.build.isoImage` - Build live ISO

## Deployment (deploy-rs)
- `just deploy <hostname>` - Deploy to specific host (builds locally, activates remotely)
- `just deploy brumstellar` - Deploy to brumstellar
- `just deploy sas` - Deploy to sas server
- `just deploy anteater` - Deploy to anteater PC

## Secrets Management (sops-nix)
- `just sops-edit` - Edit secrets.yaml with sops (uses EDITOR=nvim)
- `just sops-update` - Update secret keys after editing .sops.yml
- `just sops-ssh-to-age` - Generate age key from host SSH key

## Testing
No traditional unit tests. Validate configurations by:
1. Building: `nix build .#nixosConfigurations.<hostname>.config.system.build.toplevel`
2. Running `nix flake check`
3. Using `nixos-rebuild test` for dry-run testing
4. Deploying to test hosts

---

# Home Manager Configuration (/home/)

## Structure
- `/home/modules/` - Shared Home Manager modules (terminal, nvim, sops, spotdl, qmk)
- `/home/{levente,katerina,gamer,work}/` - Per-user configurations
- `/home/modules/terminal/` - Terminal stack (zsh, kitty, nvim, tmux, pet)

## Build and Apply
Home Manager is integrated via `home-manager.nixosModules.home-manager` in flake.nix.
Changes are applied automatically during `nixos-rebuild switch`.

## File Structure Pattern
```nix
{ username, pkgs, ... }: {
  home.username = username;
  home.homeDirectory = "/home/" + username;
  home.stateVersion = "24.11";
  programs.home-manager.enable = true;

  home.packages = with pkgs; [ ... ];

  imports = [ ./module1.nix ./module2.nix ];
}
```

## Secrets in Home Manager
```nix
{ inputs, pkgs, ... }: {
  imports = [ inputs.sops-nix.homeManagerModules.sops ];

  home.packages = [ pkgs.sops ];
  sops = {
    defaultSopsFile = ../../secrets.yaml;
    validateSopsFiles = false;
    age.keyFile = ".config/sops/age/keys.txt";
    secrets = {
      "private-keys/id-brum" = {};
      "brum/zshsecrets" = {};
    };
  };
}
```

## Module Organization
- Terminal modules imported in `/home/modules/terminal/default.nix`
- User configs import from `/home/modules/` and local files
- Use `home.packages` for user-level packages
- Use `programs.*` for program configuration
- Use `services.*` for user services

---

# NixOS Configuration (/hosts/)

## Common Rules (All Hosts)

### File Structure Pattern
```nix
{ config, lib, pkgs, ... }:
let
  cfg = config.namespace.serviceName;
  helperVar = ...;
in {
  options.namespace.serviceName = { ... };
  config = lib.mkIf cfg.enable { ... };
}
```

### Module Organization
1. Start with imports at the top
2. Define local variables in `let` block
3. Define `options` using `lib.mkEnableOption` and `lib.mkOption`
4. Define `config` wrapped with `lib.mkIf` for conditional activation

### Imports
- Use relative paths: `./module.nix`, `../common/core`
- Import arrays at top of configuration blocks
- Import flake inputs in flake.nix: `inputs.sops-nix.nixosModules.sops`

### Naming Conventions
- Files: kebab-case (`docker.nix`, `lldap.nix`, `hardware-configuration.nix`)
- Variables: kebab-case for config options, camelCase for local variables
- Options: nested under namespace (`mySystems.docker`, `homelab.serviceName`)

### Global Values
Reference global user/service definitions from `config.globals.users`:
```nix
let
  serviceUser = config.globals.users.serviceName;
in {
  users.users.${serviceUser.uname} = {
    isSystemUser = true;
    group = serviceUser.gname;
    uid = serviceUser.uid;
  };
}
```

### Cache Configuration
Defined in flake.nix:
- Custom cache: cache.berky.me
- Nix community: nix-community.cachix.org
- CUDA cache: cache.nixos-cuda.org

### Nix Settings
- Flakes enabled: `nix.settings.experimental-features = [ "nix-command" "flakes" ]`
- Auto-garbage collection and optimization configured
- Unfree packages allowed globally in `hosts/common/core/base.nix`

---

# Server Configuration (/hosts/sleeper/)

## Overview
Sleeper is a dedicated homelab server running:
- Podman containers for all services
- Traefik reverse proxy with SSL
- Monitoring stack (Prometheus, Grafana, Loki)
- Media services (Jellyfin, Prowlarr, Radarr, Sonarr, etc.)
- Backup system with state directory tracking
- ZFS storage pool
- NVIDIA GPU for AI/ML workloads

## Host Config Structure
- `/hosts/sleeper/default.nix` - Main host configuration
- `/hosts/sleeper/disko.nix` - Disk partitioning (ZFS mirror)
- `/hosts/sleeper/hardware-configuration.nix` - Hardware-specific settings
- `/hosts/sleeper/levente.nix` - User-specific settings
- `/hosts/sleeper/homelab/` - Service modules

## Common Patterns for Sleeper Services

### File Structure for Homelab Services
```nix
{ config, lib, ... }:
let
  cfg = config.homelab.serviceName;
  dname = "${cfg.domain}.${config.homelab.domain}";
  serviceUser = config.globals.users.serviceName;
in {
  options.homelab.serviceName = {
    enable = lib.mkEnableOption "serviceName";
    domain = lib.mkOption {
      type = lib.types.str;
      default = "serviceName";
      description = "Subdomain where service will be served";
    };
    baseDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/service";
      description = "Path for service data storage";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.${serviceUser.uname} = {
      isSystemUser = true;
      group = serviceUser.gname;
      uid = serviceUser.uid;
    };
    users.groups.${serviceUser.gname} = { gid = serviceUser.gid; };

    sops.secrets."n100/service/secret" = { owner = serviceUser.uname; };

    services.service = {
      enable = true;
      environment = {
        SECRET_FILE = config.sops.secrets."n100/service/secret".path;
      };
    };

    homelab.traefik.routes = [{ host = cfg.domain; port = 8080; }];

    homelab.backup.stateDirs = [ cfg.baseDir ];

    homelab.homepage.admin = [{
      ServiceName = {
        href = "https://${dname}";
        siteMonitor = "https://${dname}";
        description = "Service description";
      };
    }];
  };
}
```

### Secrets Management (Server)
```nix
sops.secrets."n100/service/secret" = {
  owner = serviceUser.uname;
  group = serviceUser.gname;
};

sops.templates."n100/service/.env" = {
  content = ''
    SECRET_VAR=${config.sops.placeholder."n100/service/secret"}
  '';
  owner = serviceUser.uname;
};
```

### Traefik Route Registration
All services must register with Traefik:
```nix
homelab.traefik.routes = [{
  host = cfg.domain;
  port = 8080;
  local = false;  # Skip security features for local-only routes
}];
```

### Backup Integration
Services must declare state directories:
```nix
homelab.backup.stateDirs = [
  cfg.baseDir
  "/var/lib/private/service"
];
```

### Container Services
- Use `virtualisation.oci-containers.backend = "podman"`
- Podman auto-prune enabled globally
- DNS enabled in default network for inter-container communication
- Define in `oci-containers.containers`

### Complex Services
Split into subdirectory:
```
homelab/authelia/
  default.nix    - Main service config
  oidc.nix       - OIDC client configurations
```

### Media Services
Located in `homelab/media/`:
- Builders: transmission, prowlarr, radarr, sonarr, bazarr, recyclarr, lidarr
- Consumers: jellyfin, jellyseerr, audiobookshelf, calibre
- Shared config in `media/default.nix`

### Monitoring Stack
Located in `homelab/monitoring/`:
- Prometheus for metrics
- Grafana for dashboards
- Loki for logs

### NVIDIA GPU Support
Located in `homelab/nvidia/`:
- Default enabled for GPU-accelerated services
- Power management with configurable limit
- CUDA cache for package building

---

# Desktop/Laptop Hosts (/hosts/brumstellar, /hosts/anteater, /hosts/sas, /hosts/live/)

## Overview
Non-server hosts are desktop/laptop systems with:
- Desktop environments (GNOME on brumstellar/anteater)
- Optional features (docker, gaming, scanner, printing, nfs, etc.)
- Stylix for theming (brumstellar, anteater)
- Deployment SSH for remote updates

## Host Config Structure
- Import `hardware-configuration.nix`
- Import `stylix.nix` (brumstellar, anteater) for theming
- Import from `hosts/common/core` for base modules
- Import from `hosts/common/optional` for feature modules
- Import from `hosts/common/users` for user accounts
- Set `networking.hostName`

## Common Modules (hosts/common/)

### Core Modules (`hosts/common/core/`)
- `base.nix` - Base system (locale, timezone, nix settings, packages)
- `ssh.nix` - SSH daemon configuration
- `sops.nix` - Secrets management
- `networking.nix` - NetworkManager configuration
- `globals.nix` - Global user/service definitions (UIDs, GIDs)
- `auto-update.nix` - Automatic system updates

### Optional Modules (`hosts/common/optional/`)
- `base-gnome.nix` - GNOME desktop environment
- `docker.nix` - Docker with user management via `mySystems.docker`
- `gaming.nix` - Gaming optimizations and tools
- `nfs.nix` - Network filesystem client
- `scanner.nix` - Scanner support
- `printing.nix` - Printer support
- `sound.nix` - Audio configuration
- `tailscale.nix` - Tailscale VPN
- `usb-waekup-disable.nix` - USB wakeup disabling
- `appstores.nix` - Flatpak/other app stores
- `dualboot.nix` - Dual boot with Windows
- `deployment-ssh.nix` - SSH for remote deployments

## Optional Module Pattern
```nix
{ config, lib, pkgs, ... }:
let
  cfg = config.mySystems.docker;
in {
  options.mySystems.docker = {
    enable = lib.mkEnableOption "docker";
    users = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Users added to docker group";
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.docker.enable = true;
    users.groups.docker.members = cfg.users;
    environment.systemPackages = with pkgs; [ docker-compose ];
  };
}
```

## Stylix Usage (brumstellar, anteater)
- Imported in host config: `stylix.nixosModules.stylix`
- Theme configuration in `stylix.nix` per host
- Provides unified theming across system

## Deployment SSH
- Allows remote `nixos-rebuild` and `deploy-rs` operations
- SSH keys managed in `hosts/common/optional/deployment-ssh.nix`

---

# General Code Style Guidelines (All Sections)

## Formatting
- 2-space indentation (not tabs)
- Trailing commas in lists and attribute sets
- Comments on own line or inline after configuration
- Keep lines under ~80-100 characters when practical

## Options Definition
```nix
options.namespace.serviceName = {
  enable = lib.mkEnableOption "serviceName";

  setting = lib.mkOption {
    type = lib.types.str;
    default = "default";
    description = "Description of the setting";
  };

  list = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [];
    description = "Description of the list";
  };
};
```

## Config with Conditional Enable
```nix
config = lib.mkIf cfg.enable {
  services.serviceName = {
    enable = true;
    settings = { option = value; };
  };
};
```

## Use `with lib;`
For brevity in options-heavy files:
```nix
{ config, lib, ... }:
with lib; {
  options.namespace = mkOption { ... };
  config = mkIf cfg.enable { ... };
}
```

## `let` Bindings
Simplify repetitive expressions:
```nix
let
  cfg = config.homelab.service;
  dname = "${cfg.domain}.${config.homelab.domain}";
in {
  config = lib.mkIf cfg.enable {
    # Use dname throughout
  };
}
```

---

# Overlays

Custom package modifications in `utils/overlays/default.nix`:
```nix
modifications = final: prev: {
  packageName = prev.packageName.override {
    option = value;
  };
};
```

Custom packages in `utils/pkgs/default.nix` (currently empty).
