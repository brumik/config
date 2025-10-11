{ config, pkgs, ... }:
let work = config.globals.users.work;
in {
  sops.secrets."brum/hashed-password".neededForUsers = true;
  # It's important to include users.mutableUsers = false to ensure the user can't modify
  # their password or groups. Furthermore, if the user had already been created prior to
  # setting their password this way, their existing password will not be overwritten
  # unless this option is false.
  users.mutableUsers = false;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."${work.uname}" = {
    uid = work.uid;
    isNormalUser = true;
    description = "Work";
    extraGroups = [ "networkmanager" "wheel" ];
    hashedPasswordFile = config.sops.secrets."brum/hashed-password".path;
    shell = pkgs.zsh;
  };

  home-manager.users.work = import ../../../home/work { username = work.uname; };

  mySystems.docker.users = [ work.uname ];
}
