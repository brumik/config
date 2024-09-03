{ pkgs, ... }:
{
  # Enables i2c capabilities and ads the seated users to the group.
  hardware.i2c.enable = true;

  # installs ddcutil that can query and modify monitor settings
  # examples: brightness is code 10, sharpness is code 12
  # ddcutil setvcp 10 40 12 70
  # this sets brightness to 40 and sharpness to 70
  environment.systemPackages = [ pkgs.ddcutil ];
}
