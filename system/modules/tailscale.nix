{ username, ... }: {
  services.tailscale = {
    enable = true;
    openFirewall = true;
    useRoutingFeatures = "both";
    authKeyFile = "/home/${username}/tailscale.key";
    extraUpFlags = [
      "--reset"
      "--ssh"
    ];
  };
  services.openssh = {
    enable = true;
  };
}
