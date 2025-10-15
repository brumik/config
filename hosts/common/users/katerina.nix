{ config, pkgs, ... }:
let katerina = config.globals.users.katerina;
in {
  sops.secrets."anteater/hashed-password".neededForUsers = true;
  # It's important to include users.mutableUsers = false to ensure the user can't modify
  # their password or groups. Furthermore, if the user had already been created prior to
  # setting their password this way, their existing password will not be overwritten
  # unless this option is false.
  users.mutableUsers = false;

  users.users."${katerina.uname}" = {
    # TODO: Migrate the PC away from the 1000 uid, most installations create this automaticaly
    # uid = 1020;
    uid = katerina.uid;
    isNormalUser = true;
    description = "Katerina";
    extraGroups = [ "networkmanager" "wheel" ];
    hashedPasswordFile = config.sops.secrets."anteater/hashed-password".path;
    shell = pkgs.zsh;
  };

  home-manager.users.${katerina.uname} =
    import ../../../home/katerina { username = katerina.uname; };

  mySystems.scanner.users = [ katerina.uname ];
  mySystems.nfs.users = [ katerina.uname ];
}
