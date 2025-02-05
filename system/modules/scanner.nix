{ username }: { ... }:
{
  hardware.sane.enable = true;
  hardware.sane.brscan5.enable = true;
  users.users."${username}".extraGroups = [ "scanner" "lp" ];
}
