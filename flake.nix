{
  description = "Home system configuration";

  nixConfig = {
    # will be appended to the system-level substituters
    extra-substituters = [
      # own cache server
      "https://cache.berky.me"

      # nix community's cache server
      "https://nix-community.cachix.org"

      # CUDA cache
      "https://cache.nixos-cuda.org"
    ];

    # will be appended to the system-level trusted-public-keys
    extra-trusted-public-keys = [
      # own cache server
      "cache.berky.me:lqgkHX3lPraXCiWpPneC4L0AzujpuMUvcuVVpkALTGw="

      # nix community's cache server public key
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="

      # CUDA cache
      "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      # Allow nixvim to use its own nixpkgs. This is not optimal but currently broken
      # https://github.com/nix-community/nixvim/issues/3780
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix.url = "github:danth/stylix/master";
    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Nixos Anywhere, new deployments use disko for auto partitioning
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    deploy-rs.url = "github:serokell/deploy-rs";
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";
  };

  outputs =
    { self, nixpkgs, home-manager, stylix, disko, deploy-rs, ... }@inputs:
    let
      inherit (self) outputs;
      system = "x86_64-linux";
      commonHomeManagerConfig = {
        nixpkgs.overlays =
          [ outputs.overlays.modifications outputs.overlays.additions ];
        home-manager.extraSpecialArgs = { inherit inputs outputs; };
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.backupFileExtension = "backup";
      };

      # nixpkgs with deploy-rs overlay but force the nixpkgs package
      # Deploy-rs
      pkgs = import nixpkgs { inherit system; };
      deployPkgs = import nixpkgs {
        inherit system;
        overlays = [
          deploy-rs.overlays.default
          (self: super: {
            deploy-rs = {
              inherit (pkgs) deploy-rs;
              lib = super.deploy-rs.lib;
            };
          })
        ];
      };
      # End ot deploy-rs
    in {

      # Your custom packages and modifications, exported as overlays
      overlays = import ./utils/overlays { inherit inputs; };

      nixosConfigurations = {
        # Standalone server
        sleeper = (nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs outputs; };
          modules = [
            home-manager.nixosModules.home-manager
            commonHomeManagerConfig
            disko.nixosModules.disko
            ./hosts/sleeper
          ];
        });

        sas = (nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs outputs; };
          modules = [ ./hosts/sas ];
        });

        # Personal PC
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

        # Anteater PC
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

        # For creating a live installation ISO, bootsrapping nixos-anywhere
        nixos-live = (nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs outputs; };
          modules = [
            "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-base.nix"
            ./hosts/live
          ];
        });
      };

      # >>> deploy-rs ADDITIONS >>>
      #
      # Each host gets a deploy-rs profile. Build happens on the machine
      # running `deploy` (your server), and only activation happens remotely.
      #
      deploy = {
        nodes = {
          # The builder machine is this, so it makes no sense
          # sleeper = {
          #   hostname = "sleeper.berky.me";
          #   sshUser = "root";
          #   autoRollback = false;
          #   magicRollback = false;
          #   profiles.system = {
          #     sshUser = "root";
          #     path = deployPkgs.deploy-rs.lib.activate.nixos
          #       self.nixosConfigurations.sleeper;
          #   };
          # };

          sas = {
            hostname = "sas.berky.me";
            sshUser = "root";
            profiles.system = {
              sshUser = "root";
              path = deployPkgs.deploy-rs.lib.activate.nixos
                self.nixosConfigurations.sas;
            };
          };

          brumstellar = {
            hostname = "brumstellar.berky.me";
            sshUser = "root";
            profiles.system = {
              sshUser = "root";
              path = deployPkgs.deploy-rs.lib.activate.nixos
                self.nixosConfigurations.brumstellar;
            };
          };

          anteater = {
            hostname = "anteater.berky.me";
            sshUser = "root";
            profiles.system = {
              sshUser = "root";
              path = deployPkgs.deploy-rs.lib.activate.nixos
                self.nixosConfigurations.anteater;
            };
          };
        };

        # Optional but recommended:
        # allow deploy-rs to run sudo on remote hosts without TTY prompts.
        sshUser = "root";
      };

      checks = builtins.mapAttrs
        (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
      # <<< deploy-rs ADDITIONS <<<
    };
}
