{ config, lib, ... }:
let 
  cfg = config.mySystems.networking;
in {
  options.mySystems.networking = {
    enable = lib.mkEnalbeOption "All the hosts on the network";
  };

  config = lib.mkIf cfg.enable {
    networking.hosts = {
      "192.168.1.127" = "n100.berky.me";
      "192.168.1.100" = "brumspace.berky.me";
      "192.168.1.101" = "anteater.berky.me";
    };

    # Get static ip address instead of dhcp
    networking = {
      useDHCP = false; # Disable DHCP to allow static IP configuration
      defaultGateway = "192.168.1.1";
      nameservers = [ "192.168.1.127" ]; # Replace with your preferred DNS servers
    };
  };
};
