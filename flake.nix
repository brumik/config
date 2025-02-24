{
  description = "Home system configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim/nixos-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix.url = "github:danth/stylix/release-24.05";

    # Zen browser flake, not so stable:
    zen-browser.url = "github:0xc000022070/zen-browser-flake";

    # SOPS
    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Future, stroring sensitive info in different repo
    # rotate secrets when switching
    # mySecrets = {
    #   url = "git+ssh://git@github.com/brumik/nix-secrets.git?shallow=1";
    #   flake = false;
    # };

    # Personal packages
    # ytsum.url = "github:brumik/ytsum";
    bw-setup-secrets.url = "github:brumik/bw-setup-secrets";
    ollama-obsidian-indexer.url = "github:brumik/ollama-obsidian-indexer";
  };

  outputs = { self, sops-nix, nixpkgs, home-manager, stylix, ... } @ inputs:
  let
    inherit (self) outputs;
    system = "x86_64-linux";
    commonHomeManagerConfig =
    {
      nixpkgs.overlays = [
        outputs.overlays.unstable-packages
        outputs.overlays.modifications
        outputs.overlays.additions
      ];

      home-manager.extraSpecialArgs = { inherit inputs outputs; };
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.backupFileExtension = "backup";
    };
  in {

  # Your custom packages and modifications, exported as overlays
  overlays = import ./utils/overlays {inherit inputs;};

  nixosConfigurations = {
      nixos-n100 = (
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {inherit inputs outputs;};
          modules = [
            stylix.nixosModules.stylix
            home-manager.nixosModules.home-manager
            commonHomeManagerConfig
            ./system/n100-config.nix
            (import ./system/users/n100.nix { username = "n100"; })
          ];
        }
      );
      nixos-brumstellar = (
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {inherit inputs outputs;};
          modules = [
            stylix.nixosModules.stylix
            home-manager.nixosModules.home-manager
            commonHomeManagerConfig
            ./system/brumstellar-config.nix
            (import ./system/users/levente.nix { username = "levente"; })
            (import ./system/users/work.nix { username = "work"; })
            (import ./system/users/gamer.nix { username = "gamer"; })
          ];
        }
      );
      # Was not working, disabling until fixed
      # nixos-gaming-rig-v1 = (
      #   nixpkgs.lib.nixosSystem {
      #     inherit system;
      #     specialArgs = {inherit inputs outputs;};
      #     modules = [
      #       stylix.nixosModules.stylix
      #       home-manager.nixosModules.home-manager
      #       commonHomeManagerConfig
      #       ./system/gaming-rig-v1-config.nix
      #       (import ./system/users/gamer.nix { username = "gamer"; })
      #     ];
      #   }
      # );
      nixos-anteater = (
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {inherit inputs outputs;};
          modules = [
            stylix.nixosModules.stylix
            home-manager.nixosModules.home-manager
            commonHomeManagerConfig
            ./system/anteater-config.nix
            (import ./system/users/katerina.nix { username = "katerina"; })
          ];
        }
      );
    };
  };
}
