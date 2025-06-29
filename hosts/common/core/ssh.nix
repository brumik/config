{ ... }: {
  services.openssh = {
    enable = true;
    openFirewall = true;
    knownHosts = {
      "sleeper.berky.me/ed25519" = {
        publicKey = builtins.readFile ../../../keys/id-sleeper.pub;
        hostNames = [ "sleeper.berky.me" ];
      };
      "anteater.berky.me/ed25519" = {
        publicKey = builtins.readFile ../../../keys/id-anteater.pub;
        hostNames = [ "anteater.berky.me" ];
      };
      "brumstellar.berky.me/ed25519" = {
        publicKey = builtins.readFile ../../../keys/id-brumstellar.pub;
        hostNames = [ "anteater.berky.me" ];
      };
      "gamingrig.berky.me/ed25519" = {
        publicKey = builtins.readFile ../../../keys/id-gamingrig.pub;
        hostNames = [ "gamingrig.berky.me" ];
      };
      "github.com" = {
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
        hostNames = [ "github.com" ];
      };
    };
  };

  users.users.root = {
    openssh.authorizedKeys.keys =
      [ "${builtins.readFile ../../../keys/id-deploy.pub}" ];
  };
}
