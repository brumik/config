{ ... }: {
  networking.hostName = "nixos-levente"; # Define your hostname.

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.levente = {
    isNormalUser = true;
    description = "Levente";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
  };

  security.sudo.extraRules= [
    {  users = [ "levente" ];
      commands = [
         { command = "ALL" ;
           options= [ "NOPASSWD" ]; # "SETENV" # Adding the following could be a good idea
        }
      ];
    }
  ];
}
