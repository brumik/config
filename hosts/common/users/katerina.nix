{ config, ... }:
let uname = "katerina";
in {
  sops.secrets."anteater/hashed-password".neededForUsers = true;
  # It's important to include users.mutableUsers = false to ensure the user can't modify
  # their password or groups. Furthermore, if the user had already been created prior to
  # setting their password this way, their existing password will not be overwritten
  # unless this option is false.
  users.mutableUsers = false;

  users.users."${uname}" = {
    uid = 1000;
    isNormalUser = true;
    description = "Katerina";
    extraGroups = [ "networkmanager" "wheel" "smbusers" ];
    hashedPasswordFile = config.sops.secrets."anteater/hashed-password".path;
  };

  home-manager.users.${uname} = import ../../../home/${uname} { username = uname; };

  mySystems.smb.users = [ uname ];
  mySystems.scanner.users = [ uname ];
}
