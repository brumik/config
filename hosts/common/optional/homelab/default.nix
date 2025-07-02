{ config, lib, ... }:
let cfg = config.homelab;
in {
  imports = [
    ./power.nix
    ./vaultwarden.nix
    ./adguard.nix
    ./ddclient.nix
    ./jellyfin.nix
    ./lldap.nix
    ./backup.nix
    ./radicale.nix
    ./languagetool.nix
    ./mealie.nix
    ./freshrss.nix
    ./traefik
    ./authelia
    ./tailscale.nix
    ./audiobooks.nix
    ./webdav.nix
    ./calibre.nix
    ./homepage.nix
    ./immich.nix
    ./home-assistant.nix
    ./ollama.nix
    ./open-ui.nix
    ./nextcloud.nix
    ./nvidia.nix
    ./timetagger.nix
    ./cache.nix
  ];

  options.homelab = {
    # This needs custom functionality for nested module definitions
    # see https://discourse.nixos.org/t/correct-way-to-disable-submodules-with-top-module-enable-option/47199/4
    enable = lib.mkEnableOption "homelab";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "berky.me";
    };

    serverIP = lib.mkOption {
      type = lib.types.str;
      default = "192.168.1.127";
    };

    gateway = lib.mkOption {
      type = lib.types.str;
      default = "192.168.1.1";
    };

    user = lib.mkOption {
      default = "share";
      type = lib.types.str;
      description = ''
        User to run the homelab services as
      '';
    };
    group = lib.mkOption {
      default = "share";
      type = lib.types.str;
      description = ''
        Group to run the homelab services as
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    users = {
      groups.${cfg.group} = { gid = 993; };
      users.${cfg.user} = {
        uid = 994;
        isSystemUser = true;
        group = cfg.group;
      };
    };

    # Do not use our own dns server 
    networking.nameservers = [ "1.1.1.1" "8.8.8.8" ]; 

    # Enable docker and set all container based services to it;
    virtualisation = {
      docker = {
        enable = true;
        autoPrune.enable = true;
      };
      oci-containers.backend = "docker";
    };

    # Enable binding on the 80 and 443 port 
    boot.kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = 0;

    # Open ports for reverse proxy
    networking.firewall.allowedTCPPorts = [ 80 443 ];
  };
}
