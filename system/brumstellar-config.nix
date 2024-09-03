{ ... }:
{
  imports = [
    ./hardware/brumstellar.nix
    ./modules/base-configuration.nix
    ./modules/nvidia.nix
    ./modules/dualboot.nix
    ./coder.nix
  ];
  
  networking.hostName = "nixos-levente"; # Define your hostname.

  # Enable xbox controllers with "xbox wireless adapter for windows"
  hardware.xone.enable = true;

  # Gaming
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; 
  };

  # With this enabled some apps have problebs with top bar and app indicator.
  # This is fixing flickering though if needed.
  # TODO: this might be not needed anymore as it is working fine without on n100
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  # Alternative is to use Xorg Gnome session until electron apps are adopting

  # Enable LLM stuff
  services.ollama = {
    enable = true;
    acceleration = "cuda";
    listenAddress = "0.0.0.0:11434";
    environmentVariables = {
        OLLAMA_ORIGINS = "*";  
    };
  };

  networking.firewall.allowedTCPPorts = [ 11434 ];

  # systemd.services.ollama-obsidian-indexer = {
  #   description = "Server to index and query LLM for obsidian notes";
  #   wantedBy = [ "multi-user.target" ];
  #   after = [ "network.target" ];
  #   environment = {
  #     APP_DEVELOPMENT = "0";
  #     APP_PORT = "11435";
  #     LLM_BASE_URL = "0.0.0.0:11434";
  #     NOTES_BASE_PATH = "/mnt/brumspace/home/Drive/01 - Private/MainVault";
  #     INDEXES_PERSIST_DIR = "/home/levente/.config/ollama-obsidian-indexer/storage";
  #   };
  #   serviceConfig = {
  #     ExecStart = "${pkgs.ollama-obsidian-indexer}/bin/ollama_obsidian_indexer";
  #   };
  # };
  #
  # networking.firewall.allowedTCPPorts = [ 11435 ];
  # End Enable LLM stuff

  # WOL
  networking.interfaces.enp7s0.wakeOnLan = {
    enable = true;
    policy = [ "magic" ];
  };
}
