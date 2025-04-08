{ ... }:
{
  services.openssh = {
    enable = true;
    openFirewall = true;
    knownHosts = {
      "n100.berky.me/ed25519" = {
        publicKey = builtins.readFile ../../../keys/id-n100.pub;
        hostNames = [ "n100.berky.me" ];
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
    };
  };

  users.users.root = {
    openssh.authorizedKeys.keys = [
      "${builtins.readFile ../../../keys/id-brum.pub}"
    ];
  };
}
