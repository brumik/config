{ config, ... }:
let uname = "levente";
in {
  sops.secrets."brum/hashed-password".neededForUsers = true;
  # It's important to include users.mutableUsers = false to ensure the user can't modify
  # their password or groups. Furthermore, if the user had already been created prior to
  # setting their password this way, their existing password will not be overwritten
  # unless this option is false.
  users.mutableUsers = false;

  users.users."${uname}" = {
    uid = 1010;
    isNormalUser = true;
    description = "Brum";
    extraGroups = [ "networkmanager" "wheel" ];
    hashedPasswordFile = config.sops.secrets."brum/hashed-password".path;
  };

  home-manager.users."${uname}" =
    import ../../../home/levente { username = "levente"; };

  mySystems.smb.users = [ uname ];
  mySystems.docker.users = [ uname ];
  mySystems.scanner.users = [ uname ];
}
