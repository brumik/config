{ config, pkgs, ... }:
let levente = config.globals.users.levente;
in {
  sops.secrets."brum/hashed-password".neededForUsers = true;
  # It's important to include users.mutableUsers = false to ensure the user can't modify
  # their password or groups. Furthermore, if the user had already been created prior to
  # setting their password this way, their existing password will not be overwritten
  # unless this option is false.
  users.mutableUsers = false;

  users.users."${levente.uname}" = {
    uid = levente.uid;
    isNormalUser = true;
    description = "Brum";
    extraGroups = [ "networkmanager" "wheel" ];
    hashedPasswordFile = config.sops.secrets."brum/hashed-password".path;
    shell = pkgs.zsh;
  };

  home-manager.users."${levente.uname}" =
    import ../../../home/levente { username = levente.uname; };

  mySystems.docker.users = [ levente.uname ];
  mySystems.scanner.users = [ levente.uname ];
  mySystems.nfs.users = [ levente.uname ];
}
