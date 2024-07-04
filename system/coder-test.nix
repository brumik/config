{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    unstable.coder
  ];

  virtualisation.docker.enable = true;
  users.users.coder.extraGroups = ["docker"];
  services.coder = {
    enable = true;
    listenAddress = "0.0.0.0:3000";
    user = "coder";
    package = pkgs.unstable.coder;
  };
}
