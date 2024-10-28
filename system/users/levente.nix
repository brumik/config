{ username }: { ... }:
{
  imports = [
    (import ../modules/docker.nix { inherit username; })
    (import ../modules/smb.nix { inherit username; })
    ../modules/monitorcontroll.nix
  ];
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."${username}" = {
    isNormalUser = true;
    initialPassword = "passwd";
    description = "Brum";
    extraGroups = [ "networkmanager" "wheel" "smbusers" ];
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
