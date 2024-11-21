{ username }: { ... }:
{
  imports = [
    (import ../modules/smb.nix { inherit username; })
    (import ../modules/docker.nix { inherit username; })
  ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."${username}" = {
    uid = 1011;
    isNormalUser = true;
    initialPassword = "passwd";
    description = "Work";
    extraGroups = [ "networkmanager" "wheel" ];
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
