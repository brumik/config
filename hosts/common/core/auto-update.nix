{ ... }:
{
  system.autoUpgrade = {
    enable = true;
    flake = "github:brumik/config";
    flags = [
      "--accept-flake-config"
    ];
    dates = "Tue 4:30"; # Sunday at 5 PM
  };
}
