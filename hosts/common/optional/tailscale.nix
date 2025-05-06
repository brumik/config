{ username }: { ... }: {
  services.tailscale = {
    enable = false;
    openFirewall = true;
    useRoutingFeatures = "server";
    # authKeyFile = "/home/${username}/tailscale.key";
    authKeyFile = "/etc/tailscale-key.txt";
    extraUpFlags = [
      # These are for servers only. If you want to use it for personal PC remove
      "--accept-routes"
      "--advertise-exit-node"
      "--ssh"
      "--reset"
    ];
  };
  services.openssh = {
    enable = true;
  };
}
