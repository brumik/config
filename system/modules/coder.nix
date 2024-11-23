{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    unstable.coder
  ];

  virtualisation.docker.enable = true;
  users.users.coder.extraGroups = ["docker"];
  services.coder = {
    enable = true;
    listenAddress = "0.0.0.0:11000";
    accessUrl = "https://coder.berky.me";
    user = "coder";
    package = pkgs.unstable.coder;
  };
  networking.firewall.allowedTCPPorts = [ 11000 ];
}
