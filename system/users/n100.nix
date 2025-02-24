{ username }: { ... }:
{
  imports = [
    (import ../modules/docker.nix { inherit username; })
    (import ../modules/smb.nix { inherit username; })
    # (import ../modules/tailscale.nix { inherit username; })
  ];
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."${username}" = {
    uid = 1000;
    isNormalUser = true;
    initialPassword = "passwd";
    description = "Brum";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  users.users.root = {
    openssh.authorizedKeys.keys = [
      "${builtins.readFile ../../keys/id-brum.pub}"
    ];
  };


  home-manager.users.${username} = import ../../home/${username} { inherit username; };

  security.sudo.extraRules = [
    {
      users = [ username ];
      commands = [
        {
          command = "ALL" ;
          options= [ "NOPASSWD" ]; 
        }
      ];
    }
  ];
}
