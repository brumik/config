{
  description = "Home system configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim/nixos-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix.url = "github:danth/stylix";

    # Personal packages
    ytsum.url = "github:brumik/ytsum";
    bw-setup-secrets.url = "github:brumik/bw-setup-secrets";
    ollama-obsidian-indexer.url = "github:brumik/ollama-obsidian-indexer";
  };

  outputs = { self, nixpkgs, home-manager, stylix, nix-darwin, ... } @ inputs:
  let
    inherit (self) outputs;
    system = "x86_64-linux";
  in {
  # Your custom packages and modifications, exported as overlays
  overlays = import ./utils/overlays {inherit inputs;};

  darwinConfigurations = {
    levente-berky-mbp = 
      let
        username = "levente.berky";
        system = "aarch64-darwin";
      in nix-darwin.lib.darwinSystem {
        inherit system;
        modules = [
          stylix.darwinModules.stylix
          ./system/darwin-system.nix
          home-manager.darwinModules.home-manager
          {
            nixpkgs.overlays = [
              outputs.overlays.unstable-packages
              outputs.overlays.modifications
              outputs.overlays.additions
            ];
            home-manager.extraSpecialArgs = {inherit inputs outputs;};
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.verbose = true;
            home-manager.users."levente.berky" = import ./home/levente-mac { username = "levente"; };
            home-manager.backupFileExtension = "backup";
          }
        ];
      };
  };

  nixosConfigurations = {
      nixos-levente = (
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {inherit inputs outputs;};
          modules = [
            stylix.nixosModules.stylix
            ./system/brumstellar-config.nix
            (import ./system/users/levente.nix { username = "levente"; })
            home-manager.nixosModules.home-manager
            {
              nixpkgs.overlays = [
                outputs.overlays.unstable-packages
                outputs.overlays.modifications
                outputs.overlays.additions
              ];

              home-manager.extraSpecialArgs = {inherit inputs outputs;};
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.levente = import ./home/levente { username = "levente"; };
              home-manager.backupFileExtension = "backup";
            }
          ];
        }
      );
      nixos-n100 = (
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {inherit inputs outputs;};
          modules = [
            stylix.nixosModules.stylix
            ./system/n100-config.nix
            (import ./system/users/levente.nix { username = "levente"; })
            home-manager.nixosModules.home-manager
            {
              nixpkgs.overlays = [
                outputs.overlays.unstable-packages
                outputs.overlays.modifications
                outputs.overlays.additions
              ];

              home-manager.extraSpecialArgs = {inherit inputs outputs; };
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.levente = import ./home/levente { username = "levente"; };
              home-manager.backupFileExtension = "backup";
            }
          ];
        }
      );
      nixos-katerina = (
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {inherit inputs outputs;};
          modules = [
            ./system/anteater.config.nix
            (import ./system/users/katerina.nix { username = "katerina"; })
            home-manager.nixosModules.home-manager
            {
              nixpkgs.overlays = [
                outputs.overlays.unstable-packages
                outputs.overlays.modifications
                outputs.overlays.additions
              ];

              home-manager.extraSpecialArgs = {inherit inputs outputs;};
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.katerina = import ./home/katerina { username = "katerina"; };
            }
          ];
        }
      );
    };
  };
}
