{ username }: { config, pkgs, ... }:
let
  options = ["x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s,credentials=${config.sops.secrets."anteater/smb-credentials".path},gid=${toString config.users.groups.smbusers.name},file_mode=0664,dir_mode=0775"];

in {
  imports = [
    (import ../modules/smb.nix { inherit username; })
  ];
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."${username}" = {
    uid = 1000;
    isNormalUser = true;
    initialPassword = "passwd";
    description = "Katerina";
    extraGroups = [ "networkmanager" "wheel" "smbusers" ];
  };

  home-manager.users.${username} = import ../../home/${username} { inherit username; };

  # Temporary
  users.groups.smbusers = {};

  environment.systemPackages = [ pkgs.cifs-utils ];
  fileSystems."/home/${username}/brumspace/share" = {
    device = "//192.168.1.2/share";
    fsType = "cifs";
    inherit options;
  };
  fileSystems."/home/${username}/brumspace/video" = {
    device = "//192.168.1.2/video";
    fsType = "cifs";
    inherit options;
  };
  fileSystems."/home/${username}/brumspace/home" = {
    device = "//192.168.1.2/home";
    fsType = "cifs";
    inherit options;
  };
}
