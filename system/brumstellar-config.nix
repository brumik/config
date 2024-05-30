{ pkgs, ... }:
{
  imports = [
    ./hardware/brumstellar.nix
    ./modules/base-configuration.nix
    ./modules/nvidia.nix
    ./modules/dualboot.nix
    ./modules/docker.nix
    ./modules/smb.nix
    ./modules/tailscale.nix
  ];

  services.ollama = {
    enable = true;
    acceleration = "cuda";
    listenAddress = "0.0.0.0:11434";
    environmentVariables = {
        OLLAMA_ORIGINS = "*";  
    };
  };

  systemd.services.ollama-obsidian-indexer = {
    description = "Server to index and query LLM for obsidian notes";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    environment = {
      APP_DEVELOPMENT = "0";
      APP_PORT = "11435";
      LLM_BASE_URL = "0.0.0.0:11434";
      NOTES_BASE_PATH = "/mnt/brumspace/home/Drive/01 - Private/MainVault";
      INDEXES_PERSIST_DIR = "/home/levente/.config/ollama-obsidian-indexer/storage";
    };
    serviceConfig = {
      ExecStart = "${pkgs.ollama-obsidian-indexer}/bin/ollama_obsidian_indexer";
    };
  };

  networking.firewall.allowedTCPPorts = [ 11434 11435 ];

  # WOL
  networking.interfaces.enp7s0.wakeOnLan = {
    enable = true;
    policy = [ "magic" ];
  };
}
