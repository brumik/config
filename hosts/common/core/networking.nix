{ ... }: {
  networking.hosts = {
    "192.168.2.129" = [ "sleeper.berky.me" ];
    "192.168.2.100" = [ "brumstellar.berky.me" ];
    "192.168.2.101" = [ "anteater.berky.me" ];
    "192.168.2.102" = [ "gamingrig.berky.me" ];
  };
}
