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

  # Enable LLM stuff
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
  # End Enable LLM stuff

  # Styling
  stylix = {
    enable = true;
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-frappe.yaml";
    image = ../wallpapers/forest-5120x1440.jpg;

    fonts = { 
      monospace = {
        package = pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; };
        name = "JetBrainsMono Nerd Font";
      };
      sansSerif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Sans";
      };
      serif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Serif";
      };
    };

    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 24;
    };

    fonts.sizes = {
      terminal = 14;
      applications = 10;
      desktop = 10;
      popups = 10;
    };
  };

  # WOL
  networking.interfaces.enp7s0.wakeOnLan = {
    enable = true;
    policy = [ "magic" ];
  };
}
