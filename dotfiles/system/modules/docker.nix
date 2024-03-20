{ pkgs, ... }: {
  virtualisation.docker.enable = true;
  
  # needs to add user group when used
  # users.users.levente.extraGroups = ["docker"];
  environment.systemPackages = with pkgs; [
    docker-compose
    # distrobox
  ];
}
