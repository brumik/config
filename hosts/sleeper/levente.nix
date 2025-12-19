{ config, pkgs, ... }:
let levente = config.globals.users.levente;
in {
  sops.secrets."brum/hashed-password".neededForUsers = true;

  users.mutableUsers = false;
  users.users."${levente.uname}" = {
    uid = levente.uid;
    isNormalUser = true;
    description = "Brum";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    hashedPasswordFile = config.sops.secrets."brum/hashed-password".path;
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys =
      [ "${builtins.readFile ../../keys/id-brum.pub}" ];
  };

  home-manager.users."${levente.uname}" =
    import ../../home/levente/default-term.nix { username = levente.uname; };
}
