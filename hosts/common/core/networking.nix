{ ... }: {
  services.openssh.enable = true;

  networking.hosts = {
    "192.168.1.129" = [ "sleeper.berky.me" ];
    "192.168.1.127" = [ "n100.berky.me" ];
    "192.168.1.100" = [ "brumspace.berky.me" ];
    "192.168.1.101" = [ "anteater.berky.me" ];
    "192.168.1.102" = [ "gamingrig.berky.me" ];
  };

  # Get static ip address instead of dhcp
  # This is not working now and just using reserved addresses
  # networking = {
  #   useDHCP = true; # Disable DHCP to allow static IP configuration
  #   defaultGateway = "192.168.1.1";
  #   nameservers = [ "192.168.1.127" ]; # Replace with your preferred DNS servers
  # };
}
