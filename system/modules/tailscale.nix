{ username }: { ... }: {
  services.tailscale = {
    enable = true;
    openFirewall = true;
    useRoutingFeatures = "server";
    authKeyFile = "/home/${username}/tailscale.key";
    extraUpFlags = [
      "--reset"
    ];
  };
  services.openssh = {
    enable = true;
  };
}
