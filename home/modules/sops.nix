{ inputs, pkgs, ... }: {
  imports = [ inputs.sops-nix.homeManagerModules.sops ];

  home.packages = [ pkgs.sops ];
  sops = {
    defaultSopsFile = ../../secrets.yaml;
    validateSopsFiles = false;

    age.keyFile = ".config/sops/age/keys.txt";

    secrets = {
      "private-keys/id-brum" = { path = ".ssh/id_ed25519"; };
      "brum/zshsecrets" = { path = ".zshsecrets"; };
    };
  };
}
