{ config, lib, ... }:
let
  cfg = config.homelab;
  share = config.globals.users.share;
in {
  imports = [
    ./power.nix
    ./vaultwarden.nix
    ./adguard.nix
    ./ddclient.nix
    ./lldap.nix
    ./backup.nix
    ./radicale.nix
    ./mealie.nix
    ./freshrss.nix
    ./traefik
    ./authelia
    ./tailscale.nix
    ./homepage.nix
    ./immich.nix
    ./home-assistant.nix
    ./ollama.nix
    ./open-webui.nix
    ./nextcloud.nix
    ./nvidia
    ./cache.nix
    ./zfs.nix
    ./email.nix
    ./auto-update.nix
    ./stirling-pdf.nix
    ./kiwix.nix
    ./glances.nix
    ./media
    ./nfs.nix
    ./smart.nix
    ./whislist.nix
    ./printing.nix
    ./monitoring
    ./minecraft.nix
  ];

  options.homelab = {
    # This needs custom functionality for nested module definitions
    # see https://discourse.nixos.org/t/correct-way-to-disable-submodules-with-top-module-enable-option/47199/4
    enable = lib.mkEnableOption "homelab";

    domain = lib.mkOption {
      type = lib.types.str;
      example = "berky.me";
    };

    serverIP = lib.mkOption {
      type = lib.types.str;
      example = "192.168.1.127";
    };

    gateway = lib.mkOption {
      type = lib.types.str;
      example = "192.168.1.1";
    };

    subnet = lib.mkOption {
      type = lib.types.str;
      example = "192.168.1.0/24";
    };

    user = lib.mkOption {
      default = share.uname;
      type = lib.types.str;
      description = ''
        User to run the homelab services as
      '';
    };

    group = lib.mkOption {
      default = share.gname;
      type = lib.types.str;
      description = ''
        Group to run the homelab services as
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    users = {
      groups.${cfg.group} = { gid = share.gid; };
      users.${cfg.user} = {
        uid = share.uid;
        isSystemUser = true;
        group = share.gname;
      };
    };

    # Do not use only our own dns server 
    # This is not needed anymore, we use the Router's adguard
    # networking.nameservers = [ cfg.serverIP "1.1.1.1" "8.8.8.8" ];

    networking.domain = cfg.domain;

    # Enable docker and set all container based services to it;
    virtualisation = {
      podman = {
        enable = true;
        autoPrune.enable = true;
        dockerCompat = true;

        # Required for containers under podman-compose to be able to talk to each other.
        defaultNetwork.settings.dns_enabled = true;
      };
      oci-containers.backend = "podman";
    };

    # Enable binding on the 80 and 443 port 
    boot.kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = 0;

    # Open ports for reverse proxy
    networking.firewall.allowedTCPPorts = [ 80 443 ];
  };
}
