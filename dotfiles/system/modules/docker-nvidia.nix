{ pkgs, username, ... }: {
  virtualisation.docker.enable = true;
  virtualisation.docker.enableNvidia = true;
  # libnvidia-container does not support cgroups v2 (prior to 1.8.0)
  # https://github.com/NVIDIA/nvidia-docker/issues/1447
  systemd.enableUnifiedCgroupHierarchy = false;

  # needs to add user group when used
  users.users.${username}.extraGroups = ["docker"];
  environment.systemPackages = with pkgs; [
    docker-compose
    # distrobox
  ];
}
