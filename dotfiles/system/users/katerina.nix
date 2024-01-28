{ ... }: {
  networking.hostName = "nixos-katerina"; # Define your hostname.
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.katerina = {
    isNormalUser = true;
    description = "Katerina";
    extraGroups = [ "networkmanager" "wheel" ];
  };
  
  security.sudo.extraRules= [
    {  users = [ "katerina" ];
      commands = [
         { command = "ALL" ;
           options= [ "NOPASSWD" ]; # "SETENV" # Adding the following could be a good idea
        }
      ];
    }
  ];


}
