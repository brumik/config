{
  description = "Home system configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix.url = "github:danth/stylix/master";
    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Gaming Rig SteamOS
    jovian = {
      url = "github:Jovian-Experiments/Jovian-NixOS";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, stylix, jovian, ...
    }@inputs:
    let
      inherit (self) outputs;
      system = "x86_64-linux";
      commonHomeManagerConfig = {
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
      overlays = import ./utils/overlays { inherit inputs; };

      nixosConfigurations = {
        n100 = (nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs outputs; };
          modules = [
            ./hosts/n100
          ];
        });
        sleeper = (nixpkgs-unstable.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs outputs; };
          modules = [
            # home-manager.nixosModules.home-manager
            # commonHomeManagerConfig
            ./hosts/sleeper
          ];
        });
        brumstellar = (nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs outputs; };
          modules = [
            stylix.nixosModules.stylix
            home-manager.nixosModules.home-manager
            commonHomeManagerConfig
            ./hosts/brumstellar
          ];
        });
        # This is built with nixos-unstable
        gamingrig = (nixpkgs-unstable.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs outputs; };
          modules = [ jovian.nixosModules.default ./hosts/gamingrig ];
        });
        anteater = (nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs outputs; };
          modules = [
            stylix.nixosModules.stylix
            home-manager.nixosModules.home-manager
            commonHomeManagerConfig
            ./hosts/anteater
          ];
        });
      };
    };
}
