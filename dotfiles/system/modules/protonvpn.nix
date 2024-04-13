{ ... }: {
  networking.wg-quick.interfaces = {
    ProtonVPN-DE = {
      # IP address of this machine in the *tunnel network*
      address = [
        "10.2.0.2/32"
      ];

      # To match firewall allowedUDPPorts (without this wg
      # uses random port numbers).
      listenPort = 51820;

      # Path to the private key file.
      privateKeyFile = "/home/levente/wireguard-protonvpn-de-privatekey";

      peers = [{
        publicKey = "1493vtFUbIfSpQKRBki/1d0YgWIQwMV4AQAvGxjCNVM=";
        allowedIPs = [ "0.0.0.0/0" ];
        endpoint = "149.88.102.110:51820";
        persistentKeepalive = 25;
      }];
    };
  };
}
