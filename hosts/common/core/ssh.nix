{ ... }:
{
  services.openssh = {
    enable = true;
    knownHosts = {
      "github/ed25519" = {
        publicKey =
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
        hostNames = [ "github.com" ];
      };
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
    };
  };

  networking.hosts = {
    "192.168.1.127" = [ "n100.berky.me" ];
    "192.168.1.100" = [ "brumspace.berky.me" ];
    "192.168.1.101" = [ "anteater.berky.me" ];
  };

  users.users.root = {
    openssh.authorizedKeys.keys = [
      "${builtins.readFile ../../../keys/id-brum.pub}"
    ];
  };
}
