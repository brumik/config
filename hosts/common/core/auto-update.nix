{ ... }:
{
  system.autoUpgrade = {
    enable = true;
    flake = "github:brumik/config";
    flags = [
      "--accept-flake-config"
    ];
    dates = "Mon 8:00"; 
  };
}
