{
  description = "First flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";

    # You can access packages and modules from different nixpkgs revs
    # at the same time. Here's an working example:
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # Also see the 'unstable-packages' overlay at 'overlays/default.nix'.

    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... } @ inputs:
  let
    inherit (self) outputs;
    system = "x86_64-linux";
  in {
  # Your custom packages and modifications, exported as overlays
  overlays = import ./overlays {inherit inputs;};

  nixosConfigurations = {
      nixos-levente = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit inputs outputs;};
        modules = [
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            # home-manager.extraSpecialArgs = {inherit inputs outputs;};
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.levente = import ./home.nix;
          }
        ];
      };
    };
  };
}
