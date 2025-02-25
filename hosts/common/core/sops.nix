{ inputs, ... }: {
  imports = [ inputs.sops-nix.nixosModules.sops ];

  sops = {
    defaultSopsFile = ../../../secrets.yaml;
    validateSopsFiles = false;

    age = {
      sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      keyFile = "/var/lib/sops-nix/key.txt";
      generateKey = true;
    };

    secrets = {
      # I reference these by path so need to be here.
      "brum/smb-credentials" = { };
      "anteater/smb-credentials" = { };
      "n100/smb-credentials" = { };
      "n100/ddclient-key" = { };
    };
  };
}
