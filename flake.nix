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

  outputs = { self, nixpkgs, home-manager, stylix, nixvim, nix-darwin, ... } @ inputs:
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
            home-manager.extraSpecialArgs = {inherit inputs outputs username;};
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.verbose = true;
            home-manager.users."levente.berky" = import ./home/levente-mac;
            home-manager.backupFileExtension = "backup";
          }
        ];
      };
  };

  nixosConfigurations = {
      nixos-levente = (
      let
        username = "levente";
       in nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit inputs outputs username;};
        modules = [
          stylix.nixosModules.stylix
          ./system/brumstellar-config.nix
          ./system/users/levente.nix
          home-manager.nixosModules.home-manager
          {
            nixpkgs.overlays = [
              outputs.overlays.unstable-packages
              outputs.overlays.modifications
              outputs.overlays.additions
            ];

            home-manager.extraSpecialArgs = {inherit inputs outputs username;};
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.levente = import ./home/levente;
          }
        ];
      });
      nixos-katerina = (
      let
        username = "katerina";
      in nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit inputs outputs username;};
        modules = [
          stylix.nixosModules.stylix
          ./system/anteater.config.nix
          ./system/users/katerina.nix
          home-manager.nixosModules.home-manager
          {
            nixpkgs.overlays = [
              outputs.overlays.unstable-packages
              outputs.overlays.modifications
              outputs.overlays.additions
            ];

            home-manager.extraSpecialArgs = {inherit inputs outputs username;};
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.katerina = import ./home/katerina;
          }
        ];
      });
    };
  };
}
