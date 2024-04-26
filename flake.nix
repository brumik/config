{
  description = "Home system configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim/nixos-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ytsum.url = "github:brumik/ytsum";
  };

  outputs = { self, nixpkgs, home-manager, nixvim, ... } @ inputs:
  let
    inherit (self) outputs;
    system = "x86_64-linux";
  in {
  # Your custom packages and modifications, exported as overlays
  overlays = import ./utils/overlays {inherit inputs;};

  nixosConfigurations = {
      nixos-levente = (let username = "levente"; in nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit inputs outputs username;};
        modules = [
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
            home-manager.users.levente = import ./home/users/levente.nix;
          }
        ];
      });
      nixos-katerina = (let username = "katerina"; in nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit inputs outputs username;};
        modules = [
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
            home-manager.users.katerina = import ./home/users/katerina.nix;
          }
        ];
      });
    };
  };
}
